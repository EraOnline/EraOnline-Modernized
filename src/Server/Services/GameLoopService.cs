using Microsoft.AspNetCore.SignalR;
using EraOnline.Server.Hubs;
using EraOnline.Shared.Constants;
using EraOnline.Shared.Protocol;

namespace EraOnline.Server.Services;

/// <summary>
/// Main game loop running at 50ms tick rate (20 ticks/second).
/// VB6: GameTimer in frmMain.frm with Interval=50.
/// Each tick processes NPC AI/movement, idle detection, world state updates.
/// Also runs the NPC attack cadence timer (4000ms).
/// </summary>
public class GameLoopService : BackgroundService
{
    private readonly ILogger<GameLoopService> _logger;
    private readonly WorldState _world;
    private readonly IHubContext<GameHub> _hubContext;
    private readonly GameDataService _gameData;
    private long _tickCount;

    // NPC attack reset timer: every 4000ms (80 ticks at 50ms)
    private const int NpcAttackResetTicks = GameConstants.NpcAttackInterval / GameConstants.GameTickInterval;

    public long TickCount => _tickCount;

    public GameLoopService(
        ILogger<GameLoopService> logger,
        WorldState world,
        IHubContext<GameHub> hubContext,
        GameDataService gameData)
    {
        _logger = logger;
        _world = world;
        _hubContext = hubContext;
        _gameData = gameData;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Game loop started ({Interval}ms tick rate)", GameConstants.GameTickInterval);

        using var timer = new PeriodicTimer(TimeSpan.FromMilliseconds(GameConstants.GameTickInterval));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            _tickCount++;

            try
            {
                // NPC AI tick — run every Nth tick to simulate VB6's effective processing speed
                // on original ~700MHz hardware. VB6's 50ms timer was aspirational; real tick rate
                // was much slower due to interpreted execution and cooperative multitasking.
                if (_tickCount % GameConstants.NpcAiTickDivisor == 0)
                    await TickNpcAI();

                // NPC attack reset timer (VB6: NpcAttack_Timer every 4000ms)
                if (_tickCount % NpcAttackResetTicks == 0)
                {
                    ResetNpcAttackFlags();
                }

                // Criminal timer countdown (VB6: Criminal_Timer every 60000ms, client-side)
                // Server-authoritative: decrement every 60s (1200 ticks at 50ms)
                if (_tickCount % 1200 == 0)
                {
                    await TickCriminalTimers();
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in game loop tick {Tick}", _tickCount);
            }

            // Log every 1000 ticks (~50 seconds)
            if (_tickCount % 1000 == 0)
            {
                _logger.LogDebug("Game loop tick {Tick}", _tickCount);
            }
        }

        _logger.LogInformation("Game loop stopped at tick {Tick}", _tickCount);
    }

    /// <summary>
    /// VB6: NpcAttack_Timer — every 4000ms, reset CanAttack for all NPCs.
    /// </summary>
    private void ResetNpcAttackFlags()
    {
        foreach (var mapEntry in GetAllMapsWithPlayers())
        {
            foreach (var npc in _world.GetNpcsOnMap(mapEntry))
            {
                npc.CanAttack = true;
            }
        }
    }

    /// <summary>
    /// Decrement criminal timers for all online criminals. VB6: Criminal_Timer (client, 60s).
    /// When CriminalCount reaches 0, clear criminal flag and notify.
    /// </summary>
    private async Task TickCriminalTimers()
    {
        foreach (var player in _world.GetAllOnlinePlayers())
        {
            var ch = player.Character;
            if (ch.Criminal == 0 || ch.CriminalCount <= 0) continue;

            ch.CriminalCount--;
            if (ch.CriminalCount <= 0)
            {
                ch.Criminal = 0;
                ch.CriminalCount = 0;
                await _hubContext.Clients.Client(player.ConnectionId).SendAsync("Chat",
                    new ChatMessage("The knowledge of your criminal deeds fades out with the people and you are no longer marked as a criminal.", FontType.Info));
                // Broadcast appearance change (no longer red name)
                await _hubContext.Clients.Group(MapGroup(player.Map)).SendAsync("ChangeChar",
                    new MakeCharMessage(player.CharIndex, ch.Name, ch.Body, ch.Head,
                        player.Heading, player.X, player.Y, 2, 2, false));
                await SendStatsToPlayer(player);
            }
        }
    }

    /// <summary>
    /// Get all map IDs that have at least one player online.
    /// VB6: MapInfo(map).NumUsers > 0 check.
    /// </summary>
    private HashSet<int> GetAllMapsWithPlayers()
    {
        var maps = new HashSet<int>();
        foreach (var player in _world.GetAllOnlinePlayers())
            maps.Add(player.Map);
        return maps;
    }

    /// <summary>
    /// Process NPC AI for all active NPCs. VB6: GameTimer_Timer NPC loop.
    /// Faithful port of the probability throttling and movement type dispatch.
    /// </summary>
    private async Task TickNpcAI()
    {
        var activeMaps = GetAllMapsWithPlayers();
        if (activeMaps.Count == 0) return;

        foreach (var mapId in activeMaps)
        {
            var npcs = _world.GetNpcsOnMap(mapId);
            foreach (var npc in npcs)
            {
                if (!npc.Active) continue;
                if (npc.Map != mapId) continue; // safety check

                // VB6: Only do AI if there are users on map (already filtered by activeMaps)

                // VB6: Movement type 1 (stand) — skip entirely
                if (npc.Movement == (int)NpcMovement.Stand)
                    continue;

                // VB6: Hostile NPCs — 1/4 probability per tick
                if (npc.Hostile)
                {
                    if (Random.Shared.Next(1, 5) == 2) // VB6: RandomNumber(1,4) == 2
                        await RunNpcAI(npc);
                    continue;
                }

                // VB6: Random walk (type 2) — 1/4 probability per tick
                if (npc.Movement == (int)NpcMovement.RandomWalk)
                {
                    if (Random.Shared.Next(1, 5) == 1) // VB6: RandomNumber(1,4) == 1
                        await RunNpcAI(npc);
                    continue;
                }

                // VB6: All other movement types (3-8) — every tick
                await RunNpcAI(npc);
            }
        }
    }

    /// <summary>
    /// Run AI for a single NPC. VB6: NPCAI (GameLogic.bas:1164).
    /// Handles adjacent-tile attack checks, then movement pattern dispatch.
    /// </summary>
    private async Task RunNpcAI(NpcState npc)
    {
        // === ADJACENT ATTACK CHECKS (before movement) ===

        // VB6: Hostile NPCs check adjacent tiles for attack targets
        if (npc.Hostile)
        {
            if (await CheckAdjacentAttack(npc, isHostile: true))
                return; // Don't move if fighting
        }

        // VB6: Guard type 1 — attack adjacent criminals
        if (npc.Guard == (int)GuardType.Normal)
        {
            if (await CheckAdjacentGuardAttack(npc))
                return;
        }

        // VB6: Guard type 2 (chaotic) — attack adjacent humans/wood elves/criminals
        if (npc.Guard == (int)GuardType.Chaotic)
        {
            if (await CheckAdjacentChaoticGuardAttack(npc))
                return;
        }

        // === MOVEMENT PATTERNS ===
        switch (npc.Movement)
        {
            case (int)NpcMovement.Stand:
                break; // shouldn't reach here, but just in case

            case (int)NpcMovement.RandomWalk:
                // VB6: MoveNPCChar(NpcIndex, Int(RandomNumber(1, 7)))
                // Note: VB6 RandomNumber(1,7) returns 1-7, but directions are 1-4.
                // Values 5-7 just produce invalid directions that MoveNPCChar ignores.
                // This means random walk only succeeds ~57% of the time (4/7).
                await MoveNpcAndBroadcast(npc, (Direction)Random.Shared.Next(1, 8));
                break;

            case (int)NpcMovement.HostileChase:
                await ChaseNearbyPlayer(npc, range: 10, requireLevelCheck: true);
                break;

            case (int)NpcMovement.GuardPatrol:
                await ChaseNearbyCriminal(npc, range: 10);
                break;

            case (int)NpcMovement.BeggarFollow:
                await FollowNearbyNonGiver(npc, range: 10);
                break;

            case (int)NpcMovement.TamedFollow:
                // Tamed animals follow their owner (not yet implemented — needs Owner tracking)
                break;

            case (int)NpcMovement.ShortRangeHostile:
                await ChaseNearbyPlayer(npc, range: 3, requireLevelCheck: false);
                break;

            case (int)NpcMovement.ChaoticGuardPatrol:
                await ChaseNearbyHumanOrWoodElf(npc, range: 10);
                break;
        }
    }

    // === Adjacent Attack Checks ===

    /// <summary>
    /// VB6: NPCAI hostile adjacent check. Scan 4 adjacent tiles for a player to attack.
    /// </summary>
    private async Task<bool> CheckAdjacentAttack(NpcState npc, bool isHostile)
    {
        foreach (var dir in new[] { Direction.North, Direction.East, Direction.South, Direction.West })
        {
            var (dx, dy) = DirectionOffset(dir);
            var player = GetPlayerAt(npc.Map, npc.X + dx, npc.Y + dy);
            if (player == null) continue;
            if (player.IsDead) continue;

            npc.Heading = (int)dir;
            npc.Target = player.CharIndex;
            await BroadcastNpcFacing(npc);
            await NpcAttackUser(npc, player);
            return true;
        }
        return false;
    }

    /// <summary>VB6: Guard type 1 — attack adjacent criminals only.</summary>
    private async Task<bool> CheckAdjacentGuardAttack(NpcState npc)
    {
        foreach (var dir in new[] { Direction.North, Direction.East, Direction.South, Direction.West })
        {
            var (dx, dy) = DirectionOffset(dir);
            var player = GetPlayerAt(npc.Map, npc.X + dx, npc.Y + dy);
            if (player == null) continue;
            if (player.IsDead) continue;
            if (player.Character.Criminal != 2) continue;

            npc.Heading = (int)dir;
            npc.Target = player.CharIndex;
            await BroadcastNpcFacing(npc);
            await NpcAttackUser(npc, player);
            return true;
        }
        return false;
    }

    /// <summary>VB6: Guard type 2 (chaotic) — attack adjacent humans, wood elves, or criminals.</summary>
    private async Task<bool> CheckAdjacentChaoticGuardAttack(NpcState npc)
    {
        foreach (var dir in new[] { Direction.North, Direction.East, Direction.South, Direction.West })
        {
            var (dx, dy) = DirectionOffset(dir);
            var player = GetPlayerAt(npc.Map, npc.X + dx, npc.Y + dy);
            if (player == null) continue;
            if (player.IsDead) continue;

            var race = player.Character.Race;
            if (race != "Human" && race != "Wood Elf" && player.Character.Criminal != 2)
                continue;

            npc.Heading = (int)dir;
            npc.Target = player.CharIndex;
            await BroadcastNpcFacing(npc);
            await NpcAttackUser(npc, player);
            return true;
        }
        return false;
    }

    // === Chase/Follow Movement Patterns ===

    /// <summary>
    /// VB6: NPCAI Case 3 (hostile chase) and Case 7 (short-range hostile).
    /// Scan range x range area for any player, move toward them.
    /// </summary>
    private async Task ChaseNearbyPlayer(NpcState npc, int range, bool requireLevelCheck)
    {
        var target = FindNearbyPlayer(npc, range, (player) =>
        {
            if (player.IsDead) return false;
            if (player.Character.Criminal == 2) return true; // always chase criminals

            // VB6: CheckIfAttack — level gating
            if (requireLevelCheck && !CheckIfAttack(npc, player)) return false;

            // VB6: Case 3 checks status=0 (alive) and Hiding=0
            return true;
        });

        if (target != null)
        {
            var dir = WorldState.FindDirection(npc.X, npc.Y, target.X, target.Y);
            await MoveNpcAndBroadcast(npc, dir);
        }
    }

    /// <summary>VB6: NPCAI Case 4 — guards chase criminals within range.</summary>
    private async Task ChaseNearbyCriminal(NpcState npc, int range)
    {
        var target = FindNearbyPlayer(npc, range, (player) =>
            !player.IsDead && player.Character.Criminal == 2);

        if (target != null)
        {
            var dir = WorldState.FindDirection(npc.X, npc.Y, target.X, target.Y);
            await MoveNpcAndBroadcast(npc, dir);
        }
    }

    /// <summary>VB6: NPCAI Case 5 — beggars follow players who haven't been giving.</summary>
    private async Task FollowNearbyNonGiver(NpcState npc, int range)
    {
        // VB6: Flags.Giving = 0 and status = 0 (alive)
        // We don't have the Giving flag yet, so beggars follow everyone for now
        var target = FindNearbyPlayer(npc, range, (player) => !player.IsDead);

        if (target != null)
        {
            var dir = WorldState.FindDirection(npc.X, npc.Y, target.X, target.Y);
            await MoveNpcAndBroadcast(npc, dir);
        }
    }

    /// <summary>VB6: NPCAI Case 8 — chaotic guards chase humans, wood elves, and criminals.</summary>
    private async Task ChaseNearbyHumanOrWoodElf(NpcState npc, int range)
    {
        var target = FindNearbyPlayer(npc, range, (player) =>
        {
            if (player.IsDead) return false;
            var race = player.Character.Race;
            return race == "Human" || race == "Wood Elf" || player.Character.Criminal == 2;
        });

        if (target != null)
        {
            var dir = WorldState.FindDirection(npc.X, npc.Y, target.X, target.Y);
            await MoveNpcAndBroadcast(npc, dir);
        }
    }

    // === Helper Methods ===

    /// <summary>
    /// VB6: The nested For Y/X loop scanning a range around the NPC for a matching player.
    /// Returns the first matching player found (VB6 exits on first match).
    /// </summary>
    private PlayerState? FindNearbyPlayer(NpcState npc, int range, Func<PlayerState, bool> predicate)
    {
        // VB6 loops: For Y = npc.Y - range To npc.Y + range / For X = npc.X - range To npc.X + range
        // VB6 checks: X > MinXBorder And X < MaxXBorder (1-100)
        for (int y = npc.Y - range; y <= npc.Y + range; y++)
        {
            for (int x = npc.X - range; x <= npc.X + range; x++)
            {
                if (x < 1 || x > GameConstants.MapWidth || y < 1 || y > GameConstants.MapHeight)
                    continue;

                var player = GetPlayerAt(npc.Map, x, y);
                if (player != null && predicate(player))
                    return player;
            }
        }
        return null;
    }

    /// <summary>
    /// VB6: CheckIfAttack — returns true if NPC should chase this player.
    /// Level gating: NPC won't chase if player level > NPC level + 4 (unless player attacked first).
    /// </summary>
    private static bool CheckIfAttack(NpcState npc, PlayerState player)
    {
        if (player.Character.Level > npc.Level + 4)
        {
            // Exception: always chase if player attacked this NPC
            return player.CharIndex == npc.AttackedBy;
        }
        return true;
    }

    // === NPC Combat ===

    /// <summary>
    /// NPC attacks a player. VB6: NPCAttackUser (GameLogic.bas:2160).
    /// Gated by CanAttack (4000ms timer) and tactics dodge chance.
    /// </summary>
    private async Task NpcAttackUser(NpcState npc, PlayerState player)
    {
        var ch = player.Character;
        var callerId = player.ConnectionId;

        // VB6: Guard type 1 won't attack non-criminals
        if (npc.Guard == (int)GuardType.Normal && ch.Criminal != 2)
            return;

        // VB6: Chaotic guard (type 2) won't attack dark elves or haakis
        if (npc.Guard == (int)GuardType.Chaotic)
        {
            if (ch.Race == "Dark Elf" || ch.Race == "Haaki")
                return;
        }

        // Don't attack dead players
        if (player.IsDead) return;

        // VB6: CanAttack gate (reset every 4000ms by NpcAttack_Timer)
        if (!npc.CanAttack) return;

        // VB6: Tactics (Skill6) dodge chance
        int tacticsSkill = ch.Skills[6];
        int dodgeChance; // 1 = hit lands, anything else = dodged
        if (tacticsSkill <= 20)
        {
            dodgeChance = 1; // VB6: Luck2=1, RandomNumber(1,1) always = 1, never dodge
        }
        else if (tacticsSkill <= 50)
        {
            dodgeChance = Random.Shared.Next(1, 3); // 1/2 chance to dodge (VB6: Luck2=2)
        }
        else
        {
            dodgeChance = Random.Shared.Next(1, 3); // VB6: Luck2=2 for >50 too
        }

        // Set CanAttack to false regardless of hit/dodge (NPC swung)
        npc.CanAttack = false;

        // Dodge check
        if (dodgeChance != 1)
        {
            await _hubContext.Clients.Client(callerId).SendAsync("Chat",
                new ChatMessage($"You evaded {npc.Name}'s attack !", FontType.Info));
            return;
        }

        // Calculate damage
        int hit = Random.Shared.Next(npc.MinHit, npc.MaxHit + 1);
        hit -= ch.Def / 2;
        if (hit < 1) hit = 1;

        // Play hurt sound based on gender
        if (ch.Gender == "Male")
            await _hubContext.Clients.Group(MapGroup(player.Map))
                .SendAsync("PlaySound", new PlaySoundMessage(SoundId.MaleHurt));
        else
            await _hubContext.Clients.Group(MapGroup(player.Map))
                .SendAsync("PlaySound", new PlaySoundMessage(SoundId.FemaleScream));

        // NPC attack sound
        if (npc.Sound > 0)
            await _hubContext.Clients.Group(MapGroup(player.Map))
                .SendAsync("PlaySound", new PlaySoundMessage(npc.Sound));

        // Apply damage
        await _hubContext.Clients.Client(callerId).SendAsync("Chat",
            new ChatMessage($"{npc.Name} strikes you for {hit} !", FontType.Fight));
        ch.CurrentHp -= hit;

        // Send updated stats
        await SendStatsToPlayer(player);

        // Check player death
        if (ch.CurrentHp <= 0)
        {
            await _hubContext.Clients.Group(MapGroup(player.Map))
                .SendAsync("PlaySound", new PlaySoundMessage(SoundId.MaleHurt));
            npc.Target = 0;

            await _hubContext.Clients.Client(callerId).SendAsync("Chat",
                new ChatMessage($"The {npc.Name} has slain you!", FontType.Fight));
            await _hubContext.Clients.Group(MapGroup(player.Map)).SendAsync("Chat",
                new ChatMessage($"{ch.Name} has been slain by {npc.Name} !", FontType.Info));

            await UserDie(player);
        }
    }

    /// <summary>
    /// Player death. VB6: UserDie (GameLogic.bas:299).
    /// Ghost state, drop random item, lose EXP/gold.
    /// </summary>
    /// <summary>
    /// Kill a player. Called from NpcAttackUser (game loop) and UserAttackUser (hub).
    /// Public so GameHub can call it for PvP deaths.
    /// </summary>
    public async Task UserDieFromHub(PlayerState player) => await UserDie(player);

    private async Task UserDie(PlayerState player)
    {
        var ch = player.Character;
        var callerId = player.ConnectionId;

        // Set ghost state
        player.IsDead = true;
        ch.Food = 0;
        ch.Drink = 0;

        // Send death signal to client
        await _hubContext.Clients.Client(callerId).SendAsync("Death", true);

        // Restore HP/STA/MAN to max (VB6: ghost gets full health)
        ch.CurrentHp = ch.MaxHp;
        ch.CurrentMan = ch.MaxMan;
        ch.CurrentSta = ch.MaxSta;

        await _hubContext.Clients.Client(callerId).SendAsync("Chat",
            new ChatMessage("You have lost all food and drink", FontType.Fight));

        // Clear criminal status on death
        if (ch.Criminal == 2)
        {
            await _hubContext.Clients.Client(callerId).SendAsync("Chat",
                new ChatMessage("You are no longer a criminal.", FontType.Info));
            ch.Criminal = 0;
            ch.CriminalCount = 0;
        }

        // Lose EXP (1/6, if level > 3)
        if (ch.Level > 3)
        {
            int loseExp = ch.Exp / 6;
            ch.Exp -= loseExp;
            if (ch.Exp < 0) ch.Exp = 0;
            await _hubContext.Clients.Client(callerId).SendAsync("Chat",
                new ChatMessage($"You have lost {loseExp} experience !", FontType.Fight));
        }

        // Lose gold (1/5, if level > 5 and gold > 299)
        if (ch.Level > 5 && ch.Gold > 299)
        {
            int loseGold = ch.Gold / 5;
            ch.Gold -= loseGold;
            await _hubContext.Clients.Client(callerId).SendAsync("Chat",
                new ChatMessage($"You have lost {loseGold} gold !", FontType.Fight));
        }

        await _hubContext.Clients.Client(callerId).SendAsync("Chat",
            new ChatMessage("You are dead...", FontType.Fight));

        // Drop a random unequipped item from slots 0-4
        int dropSlot = Random.Shared.Next(0, 5);
        var inv = ch.Inventory[dropSlot];
        if (inv.ObjIndex > 0 && !inv.Equipped)
        {
            // Place on ground
            if (_world.PlaceGroundItem(player.Map, player.X, player.Y, inv.ObjIndex, inv.Amount))
            {
                var objDef = _gameData.Objects.FirstOrDefault(o => o.Id == inv.ObjIndex);
                if (objDef != null)
                {
                    await _hubContext.Clients.Group(MapGroup(player.Map)).SendAsync("MakeObj",
                        new MakeObjMessage(objDef.GrhIndex, player.X, player.Y));
                }
            }
            await _hubContext.Clients.Client(callerId).SendAsync("Chat",
                new ChatMessage($"You have lost {_gameData.Objects.FirstOrDefault(o => o.Id == inv.ObjIndex)?.Name ?? "an item"} !", FontType.Fight));

            // Remove from inventory
            inv.ObjIndex = 0;
            inv.Amount = 0;
            inv.Equipped = false;

            // Send inventory update
            await _hubContext.Clients.Client(callerId).SendAsync("InventorySlot",
                new InventorySlotMessage(dropSlot, 0, "(None)", 0, false, 0, 0));
        }

        // Change appearance to ghost (body=16, head=5)
        ch.Body = 16;
        ch.Head = 5;

        // Exit battle mode
        player.BattleMode = false;

        // Broadcast ghost appearance to map
        await _hubContext.Clients.Group(MapGroup(player.Map)).SendAsync("MoveChar",
            new MoveCharMessage(player.CharIndex, player.X, player.Y, player.Heading));
        // Send full character change (ghost body/head)
        await _hubContext.Clients.Group(MapGroup(player.Map)).SendAsync("MakeChar",
            new MakeCharMessage(player.CharIndex, ch.Name, ch.Body, ch.Head,
                player.Heading, player.X, player.Y, 2, 2));

        // Restore zone music (exit battle mode music)
        await SendMapMusicToPlayer(player);

        // Update stats
        await SendStatsToPlayer(player);
    }

    /// <summary>Send stats to a specific player (from outside the hub context).</summary>
    private async Task SendStatsToPlayer(PlayerState player)
    {
        var ch = player.Character;
        await _hubContext.Clients.Client(player.ConnectionId).SendAsync("Stats",
            new StatsMessage(
                ch.CurrentHp, ch.MaxHp, ch.CurrentMan, ch.MaxMan,
                ch.CurrentSta, ch.MaxSta, ch.Gold, ch.Exp, ch.Elu,
                ch.Food, ch.Drink, ch.MinHit, ch.MaxHit, ch.Def,
                ch.TrainingPoints, ch.Class, ch.RepRank, ch.Skills,
                ch.Criminal, ch.CriminalCount));
    }

    /// <summary>Send zone music to a specific player (for restoring after battle mode on death).</summary>
    private async Task SendMapMusicToPlayer(PlayerState player)
    {
        if (!_gameData.Maps.TryGetValue(player.Map, out var mapDef)) return;
        var musicStr = mapDef.Music;
        if (string.IsNullOrEmpty(musicStr)) return;
        var parts = musicStr.Split('-');
        if (parts.Length >= 1 && int.TryParse(parts[0], out var musicNum) && musicNum > 0)
        {
            var loop = parts.Length < 2 || parts[1] != "0";
            await _hubContext.Clients.Client(player.ConnectionId)
                .SendAsync("PlayMusic", new PlayMusicMessage(musicNum, loop));
        }
    }

    /// <summary>Move an NPC and broadcast the movement to all players on the map.</summary>
    private async Task MoveNpcAndBroadcast(NpcState npc, Direction heading)
    {
        if (_world.MoveNpc(npc, heading))
        {
            // VB6: SendData(ToMap, "MOC" & charIndex & "," & x & "," & y)
            // We reuse MoveChar message — the client already handles it for any charIndex
            await _hubContext.Clients.Group(MapGroup(npc.Map))
                .SendAsync("MoveChar", new MoveCharMessage(
                    npc.CharIndex, npc.X, npc.Y, npc.Heading));
        }
    }

    /// <summary>Broadcast NPC facing change (when turning to face a target before attacking).</summary>
    private async Task BroadcastNpcFacing(NpcState npc)
    {
        // VB6: ChangeNPCChar sends CHC with new heading
        // We send a MoveChar at current position with new heading — the client will update facing
        await _hubContext.Clients.Group(MapGroup(npc.Map))
            .SendAsync("MoveChar", new MoveCharMessage(
                npc.CharIndex, npc.X, npc.Y, npc.Heading));
    }

    /// <summary>Get a player at a specific tile position, or null.</summary>
    private PlayerState? GetPlayerAt(int map, int x, int y)
    {
        foreach (var player in _world.GetPlayersOnMap(map))
        {
            if (player.X == x && player.Y == y)
                return player;
        }
        return null;
    }

    private static (int dx, int dy) DirectionOffset(Direction dir) => dir switch
    {
        Direction.North => (0, -1),
        Direction.East => (1, 0),
        Direction.South => (0, 1),
        Direction.West => (-1, 0),
        _ => (0, 0)
    };

    /// <summary>SignalR group name for a map. Must match GameHub.</summary>
    private static string MapGroup(int map) => $"map:{map}";
}
