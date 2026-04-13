using EraOnline.Shared.Constants;
using EraOnline.Shared.Protocol;

namespace EraOnline.Client.CLI.Session;

/// <summary>
/// Tracks all game state received from the server via SignalR events.
/// The CLI equivalent of what renderer.js + client.js track in the web client.
/// </summary>
public class GameState
{
    // Identity
    public int MyCharIndex { get; set; }
    public string CharacterName { get; set; } = "";

    // Position
    public int Map { get; set; }
    public string MapName { get; set; } = "";
    public int X { get; set; }
    public int Y { get; set; }
    public int Heading { get; set; } = (int)Direction.South;

    // Stats
    public int Hp { get; set; }
    public int MaxHp { get; set; }
    public int Man { get; set; }
    public int MaxMan { get; set; }
    public int Sta { get; set; }
    public int MaxSta { get; set; }
    public int Gold { get; set; }
    public int Exp { get; set; }
    public int Elu { get; set; }
    public int Food { get; set; }
    public int Drink { get; set; }
    public int MinHit { get; set; }
    public int MaxHit { get; set; }
    public int Def { get; set; }
    public int TrainingPoints { get; set; }
    public string Class { get; set; } = "";
    public string RepRank { get; set; } = "";
    public int Criminal { get; set; }
    public int[]? Skills { get; set; }

    // State flags
    public bool BattleMode { get; set; }
    public bool IsDead { get; set; }
    public bool IsRaining { get; set; }
    public bool IsMeditating { get; set; }
    public string? TargetName { get; set; }

    // Characters visible on the current map (players + NPCs)
    public Dictionary<int, CharacterInfo> Characters { get; } = new();

    // Ground objects on current map
    public Dictionary<string, int> GroundObjects { get; } = new(); // "x,y" -> grhIndex

    // Inventory (20 slots)
    public InventorySlotInfo[] Inventory { get; } = new InventorySlotInfo[20];

    // Spell book (50 slots)
    public SpellSlotInfo[] SpellBook { get; } = new SpellSlotInfo[50];

    // Recent chat/events (ring buffer)
    public List<TimestampedEvent> RecentEvents { get; } = new();
    private int _lastReportedEventIndex;

    public GameState()
    {
        for (int i = 0; i < 20; i++) Inventory[i] = new();
        for (int i = 0; i < 50; i++) SpellBook[i] = new();
    }

    // --- Event recording ---

    public void AddEvent(string text)
    {
        lock (RecentEvents)
        {
            RecentEvents.Add(new TimestampedEvent(DateTime.Now, text));
            // Keep last 200 events
            if (RecentEvents.Count > 200)
                RecentEvents.RemoveRange(0, RecentEvents.Count - 200);
        }
    }

    /// <summary>Get events since last call to this method.</summary>
    public List<TimestampedEvent> GetNewEvents()
    {
        lock (RecentEvents)
        {
            var newEvents = RecentEvents.Skip(_lastReportedEventIndex).ToList();
            _lastReportedEventIndex = RecentEvents.Count;
            return newEvents;
        }
    }

    // --- State update methods (called by SignalR event handlers) ---

    public void SetCharIndex(int charIndex)
    {
        MyCharIndex = charIndex;
    }

    public void SetPosition(int x, int y)
    {
        X = x;
        Y = y;
    }

    public void OnMapLoad(int mapId, string mapName)
    {
        Map = mapId;
        MapName = mapName;
        Characters.Clear();
        GroundObjects.Clear();
        AddEvent($"Entered {mapName} (Map {mapId}).");
    }

    public void OnMakeChar(MakeCharMessage msg)
    {
        Characters[msg.CharIndex] = new CharacterInfo
        {
            CharIndex = msg.CharIndex,
            Name = msg.Name,
            Body = msg.Body,
            Head = msg.Head,
            Heading = msg.Heading,
            X = msg.X,
            Y = msg.Y,
            WeaponAnim = msg.WeaponAnim,
            ShieldAnim = msg.ShieldAnim,
            IsCriminal = msg.IsCriminal,
            IsMyChar = msg.CharIndex == MyCharIndex,
        };

        // Update my position if this is me
        if (msg.CharIndex == MyCharIndex)
        {
            X = msg.X;
            Y = msg.Y;
            Heading = msg.Heading;
        }
    }

    public void OnEraseChar(int charIndex)
    {
        if (Characters.TryGetValue(charIndex, out var ch))
        {
            if (!ch.IsMyChar)
                AddEvent($"{ch.Name} left the area.");
            Characters.Remove(charIndex);
        }
    }

    public void OnMoveChar(MoveCharMessage msg)
    {
        if (Characters.TryGetValue(msg.CharIndex, out var ch))
        {
            ch.X = msg.X;
            ch.Y = msg.Y;
            ch.Heading = msg.Heading;
        }

        if (msg.CharIndex == MyCharIndex)
        {
            X = msg.X;
            Y = msg.Y;
            Heading = msg.Heading;
        }
    }

    public void OnChangeChar(MakeCharMessage msg)
    {
        // Same as MakeChar but for appearance changes (equipment, morph, etc.)
        OnMakeChar(msg);
    }

    public void OnStats(StatsMessage msg)
    {
        Hp = msg.Hp; MaxHp = msg.MaxHp;
        Man = msg.Man; MaxMan = msg.MaxMan;
        Sta = msg.Sta; MaxSta = msg.MaxSta;
        Gold = msg.Gold;
        Exp = msg.Exp; Elu = msg.Elu;
        Food = msg.Food; Drink = msg.Drink;
        MinHit = msg.MinHit; MaxHit = msg.MaxHit;
        Def = msg.Def;
        TrainingPoints = msg.TrainingPoints;
        if (!string.IsNullOrEmpty(msg.Class)) Class = msg.Class;
        if (!string.IsNullOrEmpty(msg.RepRank)) RepRank = msg.RepRank;
        Criminal = msg.Criminal;
        if (msg.Skills != null) Skills = msg.Skills;
    }

    public void OnChat(ChatMessage msg)
    {
        AddEvent(msg.Text);
    }

    public void OnTarget(string text)
    {
        TargetName = text;
    }

    public void OnInventorySlot(InventorySlotMessage msg)
    {
        if (msg.Slot >= 0 && msg.Slot < 20)
        {
            Inventory[msg.Slot] = new InventorySlotInfo
            {
                ObjIndex = msg.ObjIndex,
                Name = msg.Name,
                Amount = msg.Amount,
                Equipped = msg.Equipped,
                GrhIndex = msg.GrhIndex,
                Value = msg.Value,
            };
        }
    }

    public void OnSpellSlot(SpellSlotMessage msg)
    {
        if (msg.Slot >= 0 && msg.Slot < 50)
        {
            SpellBook[msg.Slot] = new SpellSlotInfo
            {
                SpellIndex = msg.SpellIndex,
                Name = msg.Name,
                Desc = msg.Desc,
                NeedsMana = msg.NeedsMana,
            };
        }
    }

    public void OnMakeObj(MakeObjMessage msg)
    {
        GroundObjects[$"{msg.X},{msg.Y}"] = msg.GrhIndex;
    }

    public void OnEraseObj(EraseObjMessage msg)
    {
        GroundObjects.Remove($"{msg.X},{msg.Y}");
    }

    public void OnDeath(bool isDead)
    {
        IsDead = isDead;
        if (isDead) AddEvent("You have died and become a ghost.");
        else AddEvent("You have been resurrected!");
    }

    public void OnWeather(bool raining)
    {
        IsRaining = raining;
        AddEvent(raining ? "It begins to rain." : "The rain has stopped.");
    }

    public void OnMeditate(bool meditating)
    {
        IsMeditating = meditating;
    }

    // --- Query helpers ---

    public string DirectionName(int heading) => heading switch
    {
        1 => "N", 2 => "E", 3 => "S", 4 => "W", _ => "?"
    };

    public string StatusLine()
    {
        var battle = BattleMode ? "Battle:On" : "Battle:Off";
        var weather = IsRaining ? "Rain" : "Clear";
        var dead = IsDead ? " [GHOST]" : "";
        return $"{MapName} ({X},{Y}) {DirectionName(Heading)} | HP {Hp}/{MaxHp} | STA {Sta}/{MaxSta} | MAN {Man}/{MaxMan} | Gold {Gold} | {battle} | {weather}{dead}";
    }

    /// <summary>Get nearby characters (excluding self) within a given tile radius.</summary>
    public List<(CharacterInfo ch, int dist, string dir)> GetNearbyCharacters(int radius = 10)
    {
        var result = new List<(CharacterInfo, int, string)>();
        foreach (var ch in Characters.Values)
        {
            if (ch.IsMyChar) continue;
            var dx = ch.X - X;
            var dy = ch.Y - Y;
            var dist = Math.Max(Math.Abs(dx), Math.Abs(dy)); // Chebyshev distance
            if (dist <= radius)
            {
                var dir = GetRelativeDirection(dx, dy);
                result.Add((ch, dist, dir));
            }
        }
        return result.OrderBy(r => r.Item2).ToList();
    }

    private static string GetRelativeDirection(int dx, int dy)
    {
        if (dx == 0 && dy == 0) return "here";
        var parts = new List<string>();
        if (dy < 0) parts.Add("N");
        if (dy > 0) parts.Add("S");
        if (dx > 0) parts.Add("E");
        if (dx < 0) parts.Add("W");
        return string.Join("", parts);
    }
}

public class CharacterInfo
{
    public int CharIndex { get; set; }
    public string Name { get; set; } = "";
    public int Body { get; set; }
    public int Head { get; set; }
    public int Heading { get; set; }
    public int X { get; set; }
    public int Y { get; set; }
    public int WeaponAnim { get; set; }
    public int ShieldAnim { get; set; }
    public bool IsCriminal { get; set; }
    public bool IsMyChar { get; set; }
}

public class InventorySlotInfo
{
    public int ObjIndex { get; set; }
    public string Name { get; set; } = "(None)";
    public int Amount { get; set; }
    public bool Equipped { get; set; }
    public int GrhIndex { get; set; }
    public int Value { get; set; }
}

public class SpellSlotInfo
{
    public int SpellIndex { get; set; }
    public string Name { get; set; } = "";
    public string Desc { get; set; } = "";
    public int NeedsMana { get; set; }
}

public record TimestampedEvent(DateTime Timestamp, string Text);
