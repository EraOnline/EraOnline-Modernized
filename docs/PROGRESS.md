# Progress

## Current State

**Phase 2 in progress.** Renderer infrastructure complete: 810 BMP sprite sheets converted to PNG, JS rendering module with 3-pass map rendering and character compositing, served by ASP.NET Core. Needs visual verification in browser and remaining items (scrolling, animation).

Most recent log: [2026-04-01](logs/2026-04-01.md)

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
- [ ] Scrolling viewport (keyboard-driven camera movement for testing)
- [ ] Walk animation playback for animated tiles and characters
- [ ] Object renderer (items on ground - deferred, needs server state)

**Milestone:** Open browser, see an original Era Online map rendered faithfully - tiles, objects, characters with correct sprites. Hard-coded position, no networking.

## Phase 3: Client-Server Connection

Connect the client and server. Login, movement, seeing other players, chat.

- [ ] Login / character creation UI (port original forms)
- [ ] SignalR connection lifecycle (connect, authenticate, disconnect, reconnect)
- [ ] Server: handle LOGIN and NLOGIN (load/create character, place in world)
- [ ] Server: send map data, character positions, NPC positions on zone entry
- [ ] Client: receive and render other characters and NPCs from server data
- [ ] Movement: client sends direction -> server validates -> broadcast to all clients -> animate
- [ ] Map transitions: walking off zone edge loads adjacent zone (N/S/E/W exits)
- [ ] Map transitions: tile-based warps (doors, stairs, etc.)
- [ ] Chat: say, shout, emote, whisper
- [ ] Chat: ghost speech (dead players produce "oooOO OOoo" etc.)
- [ ] Commands: /WHO, /SAVE, /STATS, /REFRESH, /QUIT, /HELP, /DESC

**Milestone:** Two browser tabs connect, create characters, appear in Castlefall, walk around, cross zone boundaries, chat. Ghost speech works.

## Phase 4: Core Gameplay

Combat, items, NPCs, death. The game becomes playable.

- [ ] Inventory: pickup, drop, use, equip/unequip, give
- [ ] Equipment affects character appearance (body/weapon/shield sprites change)
- [ ] Stat bars in UI (HP, Mana, Stamina, Food, Drink, Gold, EXP progress)
- [ ] Character sheet UI (slots for head, body, weapon, shield + backpack)
- [ ] Food and drink consumption (use from inventory, affects stats)
- [ ] NPC AI: 8 movement patterns (1=stand, 2=random walk, 3=hostile chase 10 tiles, 4=guard chase criminals 10 tiles, 5=beggar follow non-givers, 6=tamed animal follow owner, 7=short-range hostile 3 tiles, 8=chaotic guard chase humans/wood elves)
- [ ] NPC AI: 2 guard types (1=normal attack criminals, 2=chaotic attack humans+wood elves+criminals)
- [ ] NPC AI: hostile detection range, level-gating (high-level NPCs don't chase low-level players)
- [ ] Combat: CTRL toggles battle mode, ALT attacks, 4000ms attack cooldown timer
- [ ] Combat: hit chance (swordmanship: <=30=1/3, <=50=1/2, >50=always), dodge chance (tactics: <=20=never, <=50=1/2-1/3), damage = random(MinHIT,MaxHIT) - DEF/2 min 1
- [ ] Combat: skill improvement on swing (1/40 chance each for tactics, swordmanship, parrying)
- [ ] Combat: sound effects (sword swing, hit, male/female hurt per gender)
- [ ] Combat: reputation changes (killing guard: -5 noble, +2 bendarr, +3 underworld; killing monster: +1 noble/common)
- [ ] NPC death: corpse + loot placement, respawn at random position on same map
- [ ] Player death: become ghost, drop random item, lose EXP/gold
- [ ] Ghost state: ghost body/head, can't interact, speech is garbled
- [ ] Resurrection: /RESSURECT at Priest of Life NPCs
- [ ] Consider (TAB): view target's HP/hit
- [ ] Left-click: inspect tile contents (items, NPCs, players - name, class, description, reputation)

**Milestone:** Can fight a troll outside Castlefall, die, become a ghost, find a Priest of Life, resurrect, go back and kill the troll, pick up loot, equip dropped weapon.

## Phase 5: Economy & Progression

Trading, leveling, skills, crafting.

- [ ] NPC trading: /TRADE, buy/sell interface, merchant skill affects prices
- [ ] Experience from kills and skill use
- [ ] Level-up system (hidden levels, ELU scaling, +5 training points, stat bumps)
- [ ] Training: /TRAIN at trainers, spend practice points on skills
- [ ] Skill use-based improvement (skills >= 10 auto-raise, < 10 require training points)
- [ ] Specialized skills (3 per character, can exceed 50)
- [ ] Class changes based on highest skill
- [ ] Equipment class restrictions (ClassForbid system)
- [ ] Crafting: woodworking (chop tree -> saw logs -> make item from drawing)
- [ ] Crafting: tailoring (sewing kit + cloth -> folded cloth -> make clothing from drawing)
- [ ] Crafting: blacksmithing (hammer + ore -> steel -> make weapon from drawing)
- [ ] Crafting: progress bars based on skill level
- [ ] Banking: /DEPOSIT, /WITHDRAW at banks
- [ ] NPC healing: /HEAL at healers (gold cost based on level)
- [ ] Campfire healing: drop log, click to light, sit nearby to regen

**Milestone:** Full economic loop. Chop trees, craft items, sell to NPCs, buy better equipment, fight monsters, level up, train skills.

## Phase 6: World Systems

The systems that make Menath feel alive.

- [ ] Criminal system: timer-based flagging, red names, /DUEL for consensual PvP
- [ ] Guard AI: chase and attack criminals, Dark Elf guards attack humans/wood elves
- [ ] Reputation system: noble/under/common rep, deity rep, overall rank titles
- [ ] Weather: rain and snow (visual effects, stamina/health drain without warm clothing)
- [ ] Spell system: spell scrolls -> inscribe to spell book, cast on target, mana cost
- [ ] Magic schools: Nature, Destruction, Enchanting (class-restricted)
- [ ] /MEDITATE for mana regeneration (skill-based speed)
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
