# Progress

## Current State

**Phase 6 in progress.** Criminal system, PvP combat, and spell system complete. Next: gathering skills (fish/mine/chop), world flavor, animal taming, weather, housing/signs.

Most recent log: [2026-04-09](logs/2026-04-09.md)

---

## Phase 1: Skeleton + Data Model

Set up the solution structure, port all VB6 data types to C#, write parsers for original data files, and verify the server can load all original game data.

- [x] Create solution and project structure (EraOnline.sln, Shared, Server, Client.Web, Client.CLI)
- [x] Port VB6 type definitions to C# (ObjectDef, NpcDef, SpellDef, MapDef, GrhEntry, HeadDef, BodyDef, AnimDef, ServerConfig)
- [x] Port game constants (Direction, ObjectType, SkillType, SoundId, FontType, NpcMovement, GuardType, GameConstants)
- [x] Define SignalR protocol message types in Shared (LoginRequest, LoginResponse, CreateCharacterRequest, ServerInfo)
- [x] Data loading from pre-converted JSON (eo-data-converter output) instead of parsing original formats directly
- [x] Server startup: loads all game data (305 objects, 278 NPCs, 16 spells, 211 maps, 4050 sprites), logs summary
- [x] Server: SignalR hub stub (GameHub - accepts connections, Ping, GetServerInfo)
- [x] Server: BackgroundService game loop stub (GameLoopService - 50ms tick rate)

**Milestone:** Server starts, loads all original game data (objects, NPCs, spells, maps, sprite defs), and logs stats. SignalR hub accepts connections.

## Phase 2: Rendering Engine

Get the original game's visuals rendering in a browser via Canvas. No server connection needed yet - load data directly.

- [x] Asset pipeline: BMP-to-PNG sprite sheet conversion in eo-data-converter (810 sheets, black->alpha transparency)
- [x] Server hosts Client.Web static files + serves eo-data-converter/data at /data
- [x] JavaScript rendering module (renderer.js): Grh system, sprite sheet loading, 3-pass map renderer
- [x] Canvas rendering: ground tiles (pass 1), fringe layer with transparency (pass 2), characters (pass 3)
- [x] Character renderer: composite head + body + weapon + shield, directional sprites, HeadOffset
- [x] Viewport: 20x11 tiles centered on camera position
- [x] Render Map 81 (Castlefall) with 33 NPCs at spawn positions
- [x] Scrolling viewport: smooth 8px/frame pixel interpolation matching VB6, screen buffer overdraw
- [x] Walk animation playback for animated tiles (water) and characters (walk cycles)
- [x] 30fps frame limiter matching original VB6 cap, FPS counter display
- [x] Test player character with collision detection (blocked tiles, NPC positions)
- [ ] Object renderer (items on ground - deferred to Phase 4, needs server state)

**Milestone:** Open browser, see an original Era Online map rendered faithfully - tiles, objects, characters with correct sprites. Hard-coded position, no networking.

## Phase 3: Client-Server Connection

Connect the client and server. Login, movement, seeing other players, chat.

- [x] Login / character creation (basic form, SHA-256 password, JSON char files)
- [x] SignalR connection lifecycle (connect, authenticate, disconnect, reconnect)
- [x] Server: handle LOGIN and NLOGIN (load/create character, place in world)
- [x] Server: send map data, character positions, NPC positions on zone entry
- [x] Client: receive and render other characters and NPCs from server data
- [x] Movement: client sends direction -> server validates -> broadcast to all clients -> animate
- [x] Client UI chrome: parchment/wood frame (interface.JPG), bottom panel (bottomface.JPG), stat bars, chat input/log, login overlay (menu.jpg)
- [x] Chat: say, shout, emote, whisper (server hub methods + broadcast)
- [x] Map transitions: walking off zone edge loads adjacent zone (N/S/E/W exits)
- [x] Map transitions: tile-based warps (doors, stairs, etc.)
- [x] Chat: ghost speech (dead players produce "oooOO OOoo" etc.)
- [x] Commands: /WHO, /SAVE, /STATS, /REFRESH, /QUIT, /HELP, /DESC
- [x] Chat logging (zone files + connection log, matching VB6)
- [x] Audio: MIDI-to-MP3 pipeline (31 tracks), 58 SFX, 14 voiceovers, zone music on map entry
- [x] Pre-game startup sequence (intro slideshow, main menu, select screen, login form)

**Milestone:** Two browser tabs connect, create characters, appear in Castlefall, walk around, cross zone boundaries, chat. Ghost speech works.

## Phase 4: Core Gameplay

Combat, items, NPCs, death. The game becomes playable.

- [x] Inventory: pickup, drop, use, equip/unequip
- [x] Equipment affects character appearance (body/weapon/shield sprites change)
- [x] Stat bars in UI (HP, Mana, Stamina, Food, Drink, Gold, EXP progress)
- [x] Character sheet UI (charsht.JPG background, backpack list, right-click context menu)
- [x] Food and drink consumption (use from inventory, affects stats)
- [x] Left-click: inspect tile contents (items, NPCs, players - name, description)
- [x] Ground items: drop to ground with sprite, pick up with G key, persist across restarts
- [x] NPC AI: 2754 live NPC instances spawned at startup, 8 movement patterns (stand, random walk, hostile chase 10 tiles, guard chase criminals, beggar follow, tamed follow, short-range hostile 3 tiles, chaotic guard patrol)
- [x] NPC AI: 2 guard types (1=normal attack criminals, 2=chaotic attack humans+wood elves+criminals)
- [x] NPC AI: hostile detection range, level-gating (CheckIfAttack: player level > NPC level + 4 = don't chase)
- [x] NPC AI: tick rate tuned to 300ms effective (NpcAiTickDivisor=6) to simulate original hardware speed
- [x] NPC AI: NPCs only tick on maps with players present (VB6 optimization preserved)
- [x] Combat: CTRL toggles battle mode with battle music (Mus5), ALT attacks, 4000ms server-authoritative cooldown
- [x] Combat: Shift+Left/Right turn in place (VB6: rotate heading without moving)
- [x] Combat: hit chance (swordmanship: <=30=1/3, <=50=1/2, >50=always), dodge chance (tactics: <=20=never, <=50=1/2), damage = random(MinHIT,MaxHIT) - DEF/2 min 1
- [x] Combat: backstab on first strike (Skill22-based chance for 8 bonus damage)
- [x] Combat: skill improvement on swing (1/40 chance each for tactics, swordmanship, parrying)
- [x] Combat: sound effects (sword swing on attempt, sword hit on connect, male hurt/female scream per gender, NPC death sound)
- [x] Combat: reputation changes (killing guard: -5 noble, +3 underworld; killing monster: +1 noble/common)
- [x] Combat: attacked NPCs become hostile and switch to chase mode
- [x] NPC death: corpse (DeathObj) + loot placement (1/LootChance, up to 4 adjacent tiles), EXP+gold rewards, respawn at random legal position on same map
- [x] NPC attack: 4000ms CanAttack timer, tactics dodge, damage with sound effects, guard type validation
- [x] Player death: become ghost (body=16, head=5), drop random unequipped item, lose EXP/6 and gold/5, clear criminal status, exit battle mode, restore zone music
- [x] Ghost state: ghost body/head, ghost speech (from Phase 3), status bar guidance
- [x] Resurrection: /RESSURECT (and /RESURRECT) at Priest of Life (npcType 61) or Healer (npcType 5), within 2 tiles, restores original appearance, chorus sound
- [x] Level-up: CheckUserLevel on kill (EXP >= ELU triggers +1 level, +5 training points, stat boosts, ELU scaling 2.0x-1.4x by bracket, spell effect sound + voice)
- [x] Consider (TAB): view target's HP/hit power for NPCs and players

**Milestone:** Can fight a troll outside Castlefall, die, become a ghost, find a Priest of Life, resurrect, go back and kill the troll, pick up loot, equip dropped weapon.

## Phase 5: Economy & Progression

Trading, leveling, skills, crafting.

- [x] NPC trading: /TRADE, buy/sell interface, merchant skill affects prices (Skill8 multiplier table)
- [x] Experience from kills and skill use (implemented in Phase 4 combat + crafting EXP)
- [x] Level-up system (implemented in Phase 4: CheckUserLevel, ELU scaling, +5 training points, stat bumps)
- [x] Training: /TRAIN at Trainer NPCs (npcType 62), spend training points on any of 28 skills
- [x] Skill use-based improvement (1/40 combat, 1/30 merchant buy, 1/150 merchant sell, 1/15 crafting, level-capped)
- [ ] Specialized skills (3 per character, can exceed 50) — data exists, enforcement deferred
- [x] Class changes based on highest skill (CheckClass called on all skill changes)
- [x] Equipment class restrictions (ClassForbid array checked in UseItem) + Level/HP check
- [x] Crafting: woodworking (saw + 2 logs → 4 planks, carpentry drawing + planks → item)
- [x] Crafting: tailoring (sewing kit + 2 cloth → 4 folded cloth, tailor drawing + folded cloth → clothing)
- [x] Crafting: blacksmithing (hammer + 2 ore → 4 steel, blacksmithing drawing + steel → weapon)
- [x] Crafting: server-authoritative progress bars based on skill level (duration = (100 - skill) * 50ms)
- [x] Banking: /DEPOSIT amount, /WITHDRAW amount, /BALANCE at Banker NPCs (npcType 48)
- [x] NPC healing: /HEAL at Healer NPCs (npcType 5), charge = level * 10 gold (cap 200)
- [x] Campfire healing: use log item → SetCamp craft → campfire on ground, adjacent = heal HP/5 + STA/5 every 10s

**Milestone:** Full economic loop. Chop trees, craft items, sell to NPCs, buy better equipment, fight monsters, level up, train skills.

## Phase 6: World Systems

The systems that make Menath feel alive.

- [x] Criminal system: timer-based flagging, red names, /DUEL for consensual PvP
- [x] PvP combat: UserAttackUser with full damage/backstab/rep/criminal/death chain
- [x] Guard AI: chase and attack criminals, Dark Elf guards attack humans/wood elves (Phase 4)
- [x] Reputation system: noble/under/common rep, deity rep (Bendarr/Veega/Zeendic/Griigo/Hyliios), rank titles (CheckRep)
- [ ] Weather: rain and snow (visual effects, stamina/health drain without warm clothing)
- [x] Spell system: spell scrolls -> inscribe to 50-slot spell book, cast on NPC/player targets, mana cost, all 16 spell effects
- [x] Magic schools: Nature, Destruction, Enchanting (class-restricted, validated on cast)
- [x] /MEDITATE for mana regeneration (server-authoritative 10s tick, skill-based speed)
- [ ] Animal taming: /TAME, skill-gated by animal type, animals persist across sessions
- [ ] NPC hailing: /HAIL for dialogue, quest hints
- [ ] NPC gossip system (randomized gossip from gossip.txt)
- [ ] Housing: house deeds, /LOCK and /UNLOCK tiles
- [ ] Signs: drop sign, write text, readable by all players
- [ ] Fishing: equip pole, click water, skill-based progress
- [ ] Mining: equip pickaxe, click stone/cliff, skill-based progress
- [ ] Map-specific music (MIDI/audio per zone)
- [ ] Ambient sound effects (forest loops, shore, birds, etc.)

**Milestone:** A living world. Weather changes, guards patrol, criminals are hunted, players pray at temples, tame animals, craft and trade, explore dungeons.

## Phase 7: Meta & Polish

Map editor, GM tools, CLI client, remaining systems.

- [ ] Map editor mode in Client.Web (tile painting, object/NPC placement, exit config)
- [ ] GM tools: morph, teleport, spawn NPCs, ban, moderate maps, modify NPC hails
- [ ] CLI client for LLM interaction (text in/out, optional screenshots)
- [ ] Message board system (in-game posting)
- [ ] Pickpocketing skill
- [ ] Disguise skill (change name to "a peasant")
- [ ] Hiding/stealth (invisible to monsters, harder for players to detect)
- [ ] Backstabbing (first-hit bonus damage)
- [ ] Etiquette and Streetwise skills (affect NPC interactions)
- [ ] Praying at priests/priestesses (/PRAY, religion skill, deity miracles)
- [ ] Clan/guild system (basic framework)
- [ ] /BUG reporting
- [ ] Poison system
- [ ] Bounty system
