# Original Game Reference

Distilled reference of how Era Online (VB6, ~1999-2000) works, derived from source code analysis. Organized by system for easy lookup during implementation. When in doubt, consult the original VB6 source in `src_vb6/`.

Key server files: `GameLogic.bas` (58 functions, 3198 lines - the core engine), `TCP.bas` (7 functions but HandleData alone is 2459 lines - the command router), `FileIO.bas` (data loading), `Checks.bas` (reputation/class/AI), `General.bas` (utilities), `Declarations.bas` (25 types, 136 constants, 52 globals), `frmMain.frm` (timers + socket events).

Key client files: `General.bas` (34 functions - game loop, data loading, movement), `Graphics.bas` (11 functions - DirectDraw rendering), `TCP.bas` (HandleData 857 lines - message parsing), `frmMain.frm` (46 functions, 41 controls including 12 timers), `Declares.bas` (20 types, 150 globals), `Sound.bas` (DirectSound + MIDI).

Duplicate files (skip during port): `ServerLogic.bas` (copy of `GameLogic.bas`), `Networking.bas` (copy of `TCP.bas`), `FileHandler.bas` (variant of `FileIO.bas`).

Use `tools/vb6-ast/bin/vb6-ast` to look up any function, type, constant, protocol message, or form control. Run `vb6-ast show Server/GameLogic:FunctionName` for details including auto-detected call graph and protocol messages.

---

## Game Tick System

The game runs on timer-driven events, not a unified game loop. Understanding the timing is critical for faithful reimplementation.

### Server Timers (frmMain.frm)
| Timer | Interval | Purpose |
|-------|----------|---------|
| GameTimer | **50ms** (20 ticks/sec) | Main game loop: NPC AI ticks, user idle detection, state processing |
| NpcAttack | **4000ms** | NPC combat: enables NPC attack flag (CanAttack) each cycle |
| rain | dynamic | Weather: rain start/stop logic, snow transitions |

### Client Timers (frmMain.frm)
| Timer | Interval | Purpose |
|-------|----------|---------|
| FPSTimer | 1000ms | Frame counter display |
| CheckClick | 900ms | Input polling / click validation |
| Attack | **4000ms** | Player attack cooldown - sends ATT to server on each tick when in battle mode |
| NPCattack | **4000ms** | Sends AT4 to server, enabling NPC to attack back |
| DoSkill | 5000ms | Crafting progress tick - sends XBX with skill progress |
| Birds | 10000ms | Ambient bird/nature sounds |
| Campfire | 10000ms | Sends CMP to server for campfire healing |
| Meditate | 10000ms | Sends REG to server for mana regen |
| EatDrink | 15000ms | Auto food/drink consumption - sends EAT/DRN |
| Thunder | 20000ms | Thunder sound during rain |
| CheckRain | 30000ms | Rain/cold damage check - sends STA |
| Criminal | 60000ms | Criminal timer countdown - sends CRM when expired |

Note: The **attack cadence** is client-driven. The client's Attack timer fires every 4s and sends ATT. The server's NpcAttack timer fires every 4s and sets `CanAttack=1` on all NPCs. The client's NPCattack timer sends AT4 to acknowledge NPC attacks. This means combat is paced at roughly 1 swing per 4 seconds for both players and NPCs.

---

## World Structure

The world of **Menath** is divided into **zones** (maps). Each zone is a 100x100 tile grid at 32x32 pixels per tile. The client viewport is 20x11 tiles with an 80px offset from the window edge.

Zones connect via:
- **Edge exits**: walking off the N/S/E/W edge of a zone loads the adjacent zone. Player position wraps (e.g., walking off Y<7 on north edge places player at Y=94 on the north zone).
- **Tile exits**: specific tiles warp to specific positions on other maps (doors, stairs, etc.).

### Starting Cities (from Server.ini)
| City | Map | X | Y | Race |
|------|-----|---|---|------|
| Castlefall | 81 | 59 | 41 | Human (most popular) |
| Bernvillage | 1 | 12 | 12 | Human |
| Angelmoor | 18 | 30 | 30 | Human |
| Gorth | 140 | 35 | 42 | Human |
| Jemhoo | 115 | 10 | 10 | Human |
| Denc | 22 | 13 | 13 | Haaki |
| Valen | 155 | 12 | 12 | Wood Elf |
| Valentfall | 169 | 12 | 12 | Mixed (Wood Elf / Dark Elf) |
| Molg | 206 | 12 | 12 | Dark Elf |
| Ug | 189 | 12 | 12 | Dark Elf |

### Map Data Structure (MapBlock)
Each tile has:
- `Blocked` (byte) - walkability
- `UserIndex` (int) - player on this tile (0 = none)
- `NpcIndex` (int) - NPC on this tile (0 = none)
- `ObjInfo` (obj) - item on this tile (ObjIndex + Amount)
- `TileExit` (WorldPos) - warp destination (map=0 means no exit)
- `Locked` (long) - owner's YourID if locked, 0 if unlocked
- `Sign` (int) - sign index if a sign is placed here
- `SignOwner` (long) - owner of the sign

### Map Metadata (MapInfo)
- `Music` - MIDI file for this zone
- `Name` - zone display name
- `NorthExit`, `SouthExit`, `WestExit`, `EastExit` - adjacent zone numbers
- `PKFREEZONE` - if 1, no PvP allowed
- `Moderated` - if 1, no chat allowed (GM-set)

---

## Races

Four playable races. Random head assigned at character creation (per race and gender).

| Race | Male Heads | Female Heads | Notes |
|------|-----------|--------------|-------|
| Human | 6-15 | 16-25 | Most flexible class options. Enemies of Dark Elves. |
| Haaki | 26-35 | 36-45 | Primitive desert people. Neutral to all. Face paint. |
| Wood Elf | 46-55 | 56-65 | Cultural/peaceful. Enemies of Dark Elves. |
| Dark Elf | 66-74 | 75-84 | Followers of Bendarr. Guards attack humans/wood elves. |

Some race/class combinations are restricted (e.g., Dark Elves can't be clerics or animal tamers, Haakis can't be pirates or fishermen).

---

## Classes (20)

Warrior, Healer, Cleric, Thief, Paladin, Bandit, Woodworker, Blacksmith, Tailor, Fisher, Animal Tamer, Merchant, Bard, Miner, Pirate, Cook, Assassin, Wizard, Druid, Enchanter.

**Class is dynamic** - it changes to match the player's highest skill. E.g., if your tailoring skill becomes your highest, your class changes to Tailor. This affects equipment restrictions (ClassForbid system on items).

### Magic-Capable Classes
| Class | School |
|-------|--------|
| Druid | Nature |
| Cleric | Nature |
| Healer | Nature |
| Wizard | Destruction |
| Paladin | Enchanting |
| Enchanter | Enchanting |

---

## Character Creation

New characters start with:
- **Stats**: 30 HP, 5 Stamina, 4 max HIT / 2 min HIT, 0 gold, 0 EXP, Level 1, ELU (exp to level) = 300
- **Inventory**: Rusty dagger (slot 3), 5 water flasks (slot 4), 5 breads (slot 5), starting suit (slot 2, auto-equipped)
- **Description**: "The Brave Adventurer"
- **Heading**: South
- **3 specialized skills** chosen at creation (can exceed 50 points; others capped at 50)
- **Random head** assigned per race/gender
- **Random YourID** (100-99999) used for house locks

---

## Stats & Leveling

### Stat Caps
| Stat | Max |
|------|-----|
| Level | 50 |
| HP | 9999 |
| Stamina | 9999 |
| Mana | 9999 |
| HIT | 9999 |
| DEF | 9999 |

### Level-Up
Triggered when EXP >= ELU (experience to level up). On level up:
- Level + 1, EXP reset to 0
- +1 Max HP, +2 Max Stamina, +15 Max Mana, +1 Max HIT, +1 Min HIT
- +5 training points
- ELU scales by level bracket:
  - Levels 1-4: ELU * 2.0
  - Levels 5-9: ELU * 1.9
  - Levels 10-14: ELU * 1.8
  - Levels 15-19: ELU * 1.7
  - Levels 20-24: ELU * 1.6
  - Levels 25-29: ELU * 1.5
  - Levels 30+: ELU * 1.4

Note: The level system is "hidden" - players don't see their level directly, just the EXP progress bar. This was a deliberate design choice to discourage power gaming.

---

## Skills (28)

Skills improve through use (if >= 10 points) and via training points at NPC trainers. Only the 3 specialized skills (chosen at creation) can exceed 50 points. Specialized skills appear in red in the skill book.

| # | Skill | Type | Description |
|---|-------|------|-------------|
| 1 | Cooking | Progress bar | Roast meat on campfire. Higher = faster. |
| 2 | Musicianship | Not implemented | Bard skill. |
| 3 | Tailoring | Progress bar | Make cloth into folded cloth, folded cloth into clothing. |
| 4 | Carpenting | Progress bar | Make logs into planks, planks into furniture. |
| 5 | Lumberjacking | Progress bar | Chop trees with lumberjack axe. Higher = faster. |
| 6 | Tactics | Passive combat | Higher = less chance of being hit. |
| 7 | Disguise | Toggle | Click diamond in skill book. May change name to "a peasant". |
| 8 | Merchant | Passive trade | Better prices. Over 70 = profit when selling to NPCs. |
| 9 | Blacksmithing | Progress bar | Make ore into steel, steel into weapons. |
| 10 | Hiding | Toggle | Click diamond. Become invisible. Creatures won't attack. |
| 11 | Magery | Progress bar | Higher = faster spell casting. Training gives +3 mana per point. |
| 12 | Lockpicking | Not implemented | |
| 13 | Stealth | Not implemented | |
| 14 | Poisoning | Not implemented | Planned: stand near target, skill-based duration. |
| 15 | Swordmanship | Passive combat | Higher = better chance of hitting foe (any weapon, not just swords). |
| 16 | Parrying | Passive combat | Reduces incoming damage. |
| 17 | Animal Taming | /TAME command | Skill-gated by animal type. Higher = faster taming. |
| 18 | Region Lore | /PRAY success | Higher = better chance of deity miracle. Once per real-life day. |
| 19 | Fishing | Progress bar | Equip fishing pole, click water. |
| 20 | Mining | Progress bar | Equip pickaxe, click stone/cliff. |
| 21 | Backstabbing | Passive combat | First hit may deal bonus damage (success/fail check). |
| 22 | Healing | Progress bar | Bandage application speed. Also affects auto-heal rate with food/drink. |
| 23 | Surviving | Progress bar | Campfire creation speed. |
| 24 | Etiquette | Passive social | Better treatment from nobles and high-standing NPCs. |
| 25 | Streetwise | Passive social | Better treatment from traders and common NPCs. |
| 26 | Meditating | /MEDITATE speed | Higher = faster mana regeneration while meditating. |
| 27 | Archery | Not implemented | |
| 28 | (unnamed) | | Slot exists in data but unused. |

---

## Combat

### Flow
1. Press **CTRL** to enter battle mode
2. Walk adjacent to target, face them
3. Press **ALT** to attack
4. Hit/miss calculated per swing
5. Press **CTRL** again to exit battle mode

### Hit Calculation (UserAttackNPC)
Attacker's **Swordmanship** (Skill16) determines hit chance:
- Skill 0-30: 1 in 3 chance to hit (random 1-3, hit on 1)
- Skill 31-50: 1 in 2 chance to hit (random 1-2, hit on 1)
- Skill 51+: always hits

Damage formula: `Hit = random(MinHIT, MaxHIT) - (target.DEF / 2)`, minimum 1.

**Backstabbing**: First swing only. If `Strike == 0`, calls `BackstabNPC` which may deal bonus damage based on backstabbing skill (Skill21). Sets `Strike = 1` to prevent repeated backstab.

**Skill improvement per swing**: 1/40 chance each for Tactics (Skill6), Swordmanship (Skill16), and Parrying (Skill17, only if shield equipped) to improve by 1 point. Skill must be >= 10 and below the level-based cap (`LevelSkill(ELV).LevelValue`).

### NPC Dodge (NPCAttackUser)
Defender's **Tactics** (Skill6) determines dodge chance:
- Skill 0-20: never dodges (random 1-1, always "hit")
- Skill 21-30: 1 in 3 chance to dodge
- Skill 31-50: 1 in 2 to 1 in 3 chance to dodge
- Skill 51+: 1 in 2 chance to dodge

NPC damage: `Hit = random(NPC.MinHIT, NPC.MaxHIT) - (user.DEF / 2)`, minimum 1.

Guards (Guard=1) skip non-criminals. Chaotic guards (Guard=2) skip Dark Elves and Haakis. NPCs only attack when `CanAttack=1` (reset by server NpcAttack timer, re-enabled by client AT4 message).

### Reputation Effects of Combat
- **Killing a guard**: Criminal flag + 60 count, -5 Noble rep, +2 Bendarr rep, +3 Underworld rep, -3 Common rep, -5 Overall rep
- **Killing a monster**: +1 Noble rep, +1 Common rep, +1 Overall rep
- **Killing a player**: Heavy penalty - -20 Noble rep, -5 Overall rep, +5 Bendarr rep, criminal flag +45 count

### PvP Rules
- Players under level 5 cannot attack or be attacked by players over level 5
- Attacking a non-criminal, non-dueling player makes you a criminal (+45 to CriminalCount)
- /DUEL for consensual PvP (no criminal flag)
- PKFREEZONE maps disable all PvP
- Attacker gains EXP from victim on PvP kill

### NPC Combat AI
- Hostile NPCs detect nearby players and chase/attack (see NPC AI section below)
- NPCs won't attack players who are "too experienced" for them (`CheckIfAttack` level comparison)
- When attacked, stationary/random NPCs switch to hostile chase (Movement changes to 3)
- Guards specifically chase criminals (Movement type 4)

---

## Death & Resurrection

### On Death
- Status set to 1 (dead/ghost)
- Body changes to ghost body (index 16), head to ghost head (index 5)
- Food and drink set to 0
- HP, Mana, Stamina fully restored (you're a ghost, not injured)
- Lose 1/6 of current EXP (if level > 3)
- Lose 1/5 of current gold (if level > 5 and gold > 299)
- A random unequipped item from inventory slots 1-5 is dropped on the ground
- Criminal flag cleared on death
- Morph cleared

### Ghost State
- Normal speech becomes "oooOO OOoo oOO OOooo"
- Shouts become "oooOOOOo OOOOOooo Ooooo"
- Emotes: "seems to try to express something. But noone can understand the ghostly movements."
- Cannot use items, trade, give, or pick up items
- Cannot cast destructive spells

### Resurrection
- Find a Priest of Life NPC, target them, type **/RESSURECT** (or /RESURRECT)
- Free of charge
- Players with the Resurrection spell can also resurrect others

---

## Items & Inventory

### Inventory
- 20 slots, each can hold up to 999,999,999 of one item type
- Equipment slots: Head, Body (clothing/armor), Weapon, Shield
- Right-click item in backpack for context menu (use, give, drop, evaluate)

### Object Types (48+)
Key types and their ObjType constants:
| Const | Type | Behavior |
|-------|------|----------|
| 1 | UseOnce | Consumable, applies stat effects |
| 2 | Weapon | Equippable, adds to HIT |
| 3 | Armour | Equippable, changes body sprite, adds DEF |
| 4 | MsgBoard | Opens message board |
| 5 | PriestNote | Displays welcome message |
| 6 | Food | Adds to food stat |
| 7 | Drink | Adds to drink stat |
| 8-11 | Instruments | Harp, Bagpipe, Guitar, Drum (musicianship) |
| 14 | Helmet | Equippable head slot |
| 15 | Clothing | Equippable, changes body sprite |
| 16 | FishingRod | Equippable, enables fishing on water tiles |
| 17 | LumberjackAxe | Equippable, enables tree chopping |
| 20 | Log | Raw material for carpentry |
| 21 | Campfire | Object index 155. Heals nearby players. |
| 22 | Saw | Used with logs to make planks |
| 23 | Spell | Scroll. USE to inscribe to spell book. |
| 24 | Shield | Equippable, adds DEF |
| 25-27 | Drawings | Carpentry/Blacksmithing/Tailoring blueprints |
| 28 | SewingKit | Used with cloth for tailoring |
| 29 | Cloth | Raw material for tailoring |
| 30 | FoldedCloth | Intermediate material for tailoring |
| 31 | Steel | Intermediate material for blacksmithing |
| 32 | Ore | Raw material for blacksmithing |
| 33 | Hammer | Tool for blacksmithing |
| 35 | Planks | Intermediate material for carpentry |
| 39 | Meat | Raw food, can be cooked |
| 40 | Corpse | Left when NPC dies |
| 41 | Gold | Currency (dropped/picked up as object) |
| 42 | Furniture | Permanent once placed (can't pick up) |
| 43 | HouseDeed | USE to read instructions for house placement |
| 44 | Shoes | Equippable |
| 45 | Bandage | USE on target to heal. Speed based on healing skill. |
| 46 | MerchantBooth | Decorative (buy from woodworker) |
| 47 | Sign | Drop to place, click to write text, readable by all |
| 48 | Pickaxe | Equippable, enables mining |

### Equipment Restrictions
Items have up to 7 `ClassForbid` fields. If the player's current class matches any forbid, they can't equip it. Items also have a `Level` field that checks against MaxHP (health requirement, not level).

---

## Crafting

All crafting uses a progress-bar system. Higher skill = faster completion. Success is guaranteed (not pass/fail) - you always produce the item, it just takes longer with low skill.

### Woodworking
1. Equip **lumberjack axe**, click a tree -> produces **logs**
2. USE a **saw**, then USE a **log** -> produces **planks**
3. USE a **carpentry drawing**, then USE **planks** -> produces the drawn item

### Tailoring
1. USE a **sewing kit** on **cloth** -> produces **folded cloth**
2. USE a **tailor drawing**, then USE **folded cloth** -> produces the drawn clothing

### Blacksmithing
1. USE a **hammer**, then USE **ore** -> produces **steel**
2. USE a **blacksmithing drawing**, then USE **steel** -> produces the drawn weapon/item

---

## NPC AI (NPCAI function)

NPC behavior is driven by two properties: `Movement` (how they move) and `Guard` (special combat rules). The `NPCAI` function runs on the 50ms server tick for each active NPC.

### Attack Phase (before movement)
1. **Hostile check**: If `Hostile=1`, scan all 4 adjacent tiles. If a player is found, face them and call `NPCAttackUser`. Exit (don't move while fighting).
2. **Guard=1 check**: Scan adjacent tiles. If a criminal player is found, attack them.
3. **Guard=2 (chaotic) check**: Scan adjacent tiles. If a Human, Wood Elf, or criminal is found, attack them.

### Movement Patterns
| Type | Name | Behavior |
|------|------|----------|
| 1 | Stand | Do nothing. Stationary NPCs (shopkeepers, priests). |
| 2 | Random walk | Move in a random direction (1-7). Wandering creatures. |
| 3 | Hostile chase | Scan 10 tiles in each direction for players. If found (and player is alive, not hiding, and `CheckIfAttack` passes), move toward them using `FindDirection`. |
| 4 | Guard patrol | Scan 10 tiles for criminal players. Move toward them. Normal guards. |
| 5 | Beggar follow | Scan 10 tiles for players who haven't been giving (`.Giving=0`) and are alive. Follow them. |
| 6 | Tamed follow | Scan 10 tiles for the specific owner (`NPCList.Owner` matches `MapData.userindex`). Follow them. |
| 7 | Short-range hostile | Same as type 3 but only scans 3 tiles. Less aggressive creatures. |
| 8 | Chaotic guard patrol | Scan 10 tiles for Humans, Wood Elves, or criminals. Move toward them. Dark Elf guards. |

Note: When a stationary (1) or random (2) NPC is attacked, its Movement is switched to 3 (hostile chase), then restored after it dies. Hidden players (`Hiding=1`) are invisible to movement type 3.

---

## NPC Trading

1. Target an NPC, type **/TRADE**
2. NPC must have `Tradeable = 0` (confusingly, 0 = can trade, 1 = can't)
3. Trading window shows NPC's inventory with prices
4. Prices affected by player's **merchant skill** (over 70 = profit)
5. NPCs have limited gold (start ~10,000). They gain gold from sales, lose from purchases.

---

## Criminal System

### Becoming Criminal
- Attacking a non-criminal, non-dueling player: +45 minutes
- Getting caught pickpocketing: adds time
- Attacking guards: instant criminal
- Casting destructive spells on players: criminal

### Criminal State
- Name appears in red when clicked
- Guards will chase and attempt to kill
- Timer counts down only while online
- Logging out resets the countdown (must serve from start again)
- Death clears criminal flag (changed in later patches - check which version we're implementing)

### Guards
- Patrol and chase criminals
- Dark Elf guards also attack humans and wood elves regardless of criminal status
- Guards are not instant-kill - they can be fought, outrun, or blocked by other players
- Guards have weapons and shields equipped

---

## Reputation

### Types
- **Noble Rep** - standing with nobility
- **Under Rep** - standing with underworld
- **Common Rep** - standing with common people
- **Per-deity Rep** - Bendarr, Veega, Zeendic, Griigo, Hyliios
- **Overall Rep** - starts at 500, changes based on actions

### Rank Titles (CheckRep thresholds on OverallRep)
| OverallRep | Title |
|------------|-------|
| < 100 | The Dreaded |
| 100-199 | The Hated |
| 200-299 | The Scum |
| 300-399 | The Suspicious |
| 400-599 | (none - neutral) |
| 600-699 | The Respected |
| 700-799 | The Admired |
| 800-899 | The Distinguished |
| 900+ | The Noble |

Starting OverallRep is 500 (neutral). Title appears when clicking on a player.

### Effects
- NPCs may refuse to trade if reputation is too low
- Killing players has severe penalty (-20 Noble, -5 Overall, +5 Bendarr)
- Killing guards: -5 Noble, +2 Bendarr, +3 Underworld, -3 Common, -5 Overall
- Killing monsters: +1 Noble, +1 Common, +1 Overall

---

## Weather

- **Rain**: chance of 1/200 per minute to start. Affects players without warm clothing (HandleRain flag on clothing items) - drains stamina/health.
- **Snow**: winter season variant. Same mechanics as rain.
- Dead players are not affected by weather.

---

## Spells & Magic

### Spell Acquisition
Find or buy spell scrolls. USE the scroll to inscribe it to your spell book. Scrolls have school markers: [N] = Nature, [E] = Enchanting, [D] = Destruction.

### Casting
Target a player/NPC, open spell book, right-click spell, select "Cast Spell". Mana is subtracted. Spell effect applied to target.

### Spell Properties
Each spell can: deal damage (HP/Mana/Stamina), heal, give stats, grant invisibility, create objects, summon creatures, paralyze, teleport, resurrect. Each spell has a graphic effect, sound, mana cost, and caster/target messages.

### Mana Regeneration
Type **/MEDITATE**. Can't move while meditating. Speed based on meditation skill. Meditation creates a visible aura (object 231) on the ground. Must exit meditation before quitting game.

---

## Housing

1. Buy a **house deed** from an architect NPC
2. USE the deed for instructions (in the original, players mailed staff to place the house)
3. Stand in a doorway, type **/LOCK** to lock the tile (uses one of your locks)
4. **/UNLOCK** to unlock (recovers the lock)
5. Lock is tied to player's `YourID` - only the owner can unlock
6. Furniture placed in houses can't be picked up once dropped

---

## Communication

### Chat Prefixes (client -> server)
| Prefix | Type | Scope | Ghost Version |
|--------|------|-------|---------------|
| `;` | Say | ToPCArea (nearby players) | "oooOO OOoo oOO OOooo" |
| `-` | Shout | ToMap (entire zone) | "oooOOOOo OOOOOooo Ooooo" |
| `:` | Emote | ToPCArea | "seems to try to express something..." |
| `\` | Whisper/Tell | ToIndex (specific player) | (check implementation) |
| `^` | GM Help | ToGM (random GM online) | N/A |

All chat is logged to zone-specific log files with timestamps.

### Key Slash Commands
| Command | Description |
|---------|-------------|
| /HAIL | Greet targeted NPC (get dialogue/quest info) |
| /TRADE | Open trading with targeted NPC |
| /TRAIN | Open training window at trainer NPC |
| /HEAL | Ask healer NPC to heal you (costs gold) |
| /RESSURECT | Ask Priest of Life to resurrect you |
| /PRAY | Pray at priest/priestess (religion skill check, once/day) |
| /TAME | Tame targeted animal |
| /MEDITATE | Toggle meditation (mana regen) |
| /DUEL | Toggle duel mode (consensual PvP) |
| /LOCK | Lock current tile position |
| /UNLOCK | Unlock current tile position |
| /DEPOSIT | Deposit gold at bank |
| /WITHDRAW | Withdraw gold from bank |
| /WHO | List all online players |
| /PLAYERS | Show player count |
| /SAVE | Save character |
| /QUIT | Save and quit |
| /STATS | Show character stats |
| /DESC [text] | Set character description |
| /BUG [text] | Report a bug |
| /HELP | Show help text |
| /REFRESH | Re-request position from server |
| /GFX | Re-request map graphics (fixes black screen) |

---

## Protocol Reference

### Routing Constants
| Const | Value | Description |
|-------|-------|-------------|
| ToIndex | 0 | Send to specific user |
| ToAll | 1 | Send to all users |
| ToMap | 2 | Send to all users on a map |
| ToPCArea | 3 | Send to all users in a user's area |
| ToNone | 4 | Send to nobody |
| ToAllButIndex | 5 | Send to all except one user |
| ToMapButIndex | 6 | Send to all on map except one user |
| ToGM | 7 | Send to online GMs |

### Server->Client Messages
| Prefix | Meaning | Sent by |
|--------|---------|---------|
| `@` | Chat/info message (text + font type) | Many (combat log, system messages) |
| `!!` | Error/disconnect message | ConnectUser, HandleData, KickBan |
| `OK` | Login successful | ConnectUser |
| `MAC` | Make character (charindex,body,head,heading,x,y,weapon,shield,name) | MakeUserChar, MakeNPCChar |
| `ERC` | Erase character (charindex) | EraseUserChar, EraseNPCChar |
| `CHC` | Change character (charindex,body,head,heading,weapon,shield) | ChangeUserChar, ChangeNPCChar |
| `MOC` | Move character (charindex,heading) | MoveUserChar, MoveNPCChar |
| `SUP` | Set user position (x,y) | MoveUserChar, WarpUserChar |
| `SUC` | Set user character index | WarpUserChar, ConnectUser |
| `SCM` | Set current map | WarpUserChar, ConnectUser |
| `SMN` | Set map name | ConnectUser |
| `SUI` | Set user index | ConnectUser |
| `SST` | Full stats (HP,MaxHP,MAN,MaxMAN,STA,MaxSTA,GLD,EXP,ELU,Food,Drink,MinHIT,MaxHIT,DEF,PracticePoints) | SendUserStatsBox |
| `SIS` | Inventory slot update (slot,objindex,name,amount,equipped,grhindex,value) | ChangeUserInv |
| `NIS` | NPC inventory slot (slot,objindex,name,amount,equipped,grhindex,value,level) | ChangeNPCInv |
| `SPL` | Spell slot update (slot,spellindex,name,grhindex,desc,needsmana) | ChangeUserSpells |
| `MOB` | Make object on ground (grhindex,x,y) | MakeObj |
| `EOB` | Erase object from ground (x,y) | EraseObj |
| `DEA` | Player died | UserDie |
| `TEN` | Near campfire (trigger healing) | DoTileEvents |
| `PLW` | Play WAV sound (sound constant) | Combat, spells, weather, etc. |
| `PL3` | Play sound effect variant | CheckUserLevel |
| `PLM` | Play music (midi filename) | WarpUserChar, ConnectUser |
| `RAI` | Start raining | rain_Timer, ConnectUser |
| `SAI` | Stop raining | rain_Timer |
| `TIP` | Tip of the day | ConnectUser |
| `PC2` | Update weapon equipment slot | UseInvItem |
| `PIC` | Update clothing equipment slot | UseInvItem |
| `PC3` | Update shield equipment slot | UseInvItem |
| `PC4` | Update head equipment slot | UseInvItem |
| `UWP` | Unequip weapon | RemoveInvItem |
| `UCL` | Unequip clothing | RemoveInvItem |
| `USH` | Unequip shield | RemoveInvItem |
| `UHE` | Unequip helmet | RemoveInvItem |
| `AT1` | Start action timer (progress bar) | HandleData (crafting) |
| `DEE` | ? (UseInvItem) | UseInvItem |
| `DOT` | ? (HandleData) | HandleData |
| `GTO` | ? (HandleData) | HandleData |
| `SGN` | Sign content | LookatTile |
| `SII` | ? (LookatTile) | LookatTile |
| `TGT` | Target info | LookatTile |
| `GMQ` | GM queue entry | SendGmQue |
| `OST` | Message board post | SendPostings |
| `WR1`/`WR2` | Map data wrapper | ConnectUser, EraseChar |

### Client->Server Messages
| Prefix | Meaning | Sent by |
|--------|---------|---------|
| `LOGIN` | Login (name,password,version,id) | TCP:Login |
| `NLOGIN` | Create character (17 fields) | TCP:Login |
| `ERASE` | Delete character | TCP:Login |
| `QIT` | Quit game | Form1 |
| `M` | Move (1=N, 2=E, 3=S, 4=W) | CheckMoveKeys |
| `LC` | Left click (x,y) | Form_MouseUp |
| `RC` | Right click | Form_MouseUp |
| `BTL` | Toggle battle mode | Form_KeyDown (CTRL) |
| `ATT` | Attack swing | Form_KeyUp (ALT) |
| `AT4` | Enable NPC attack | NPCattack_Timer |
| `COO` | Consider target (TAB) | Form_KeyDown |
| `GET` | Pick up item | GetCmd_Click |
| `USE` | Use/equip item (slot) | UseCmd_Click |
| `DRP` | Drop item (slot,amount) | DropCmd_Click |
| `DRG` | Drop gold (amount) | dropgold form |
| `GIV` | Give item to player | inventory menu |
| `EVA` | Evaluate item | inventory menu |
| `BUY` | Buy from NPC | trade form |
| `SLL` | Sell to NPC | trade form |
| `CST` | Cast spell | spellbook menu |
| `EAT` | Eat food | EatDrink_Timer, inventory |
| `DRN` | Drink | EatDrink_Timer |
| `DPT` | Deposit gold | deposit form |
| `WTH` | Withdraw gold | withdraw form |
| `DON` | Donate gold | donate form |
| `XBX` | Skill progress tick | DoSkill_Timer |
| `STP` | Stop/cancel action | cancelaction_Click |
| `CHP` | Chop tree | Form_MouseUp |
| `FSH` | Fish | Form_MouseUp |
| `MIN` | Mine | Form_MouseUp |
| `CMP` | Campfire heal | Campfire_Timer |
| `REG` | Meditate/regen mana | Meditate_Timer |
| `CRM` | Criminal timer expired | Criminal_Timer |
| `STA` | Stamina check (rain) | CheckRain_Timer |
| `BOO` | Open message board | Form_MouseUp |
| `YUP` | Post message | YourPost form |
| `HHH` | Hide | skills form |
| `UHD` | Unhide | skills form, MoveCharbyHead |
| `DGU` | Disguise | skills form |
| `UGU` | Undisguise | skills form |
| `WRI` | Write sign | signwrite form |
| `UPS` | Update spell book | Label4_Click |
| `UCS` | Update character sheet | Label6_Click |
| `UMS` | Update movement state | MoveCharbyHead |
| `RPU` | Request position update | Main (startup) |
| `PI1`/`PI2` | Pickpocket | skills form |
| `DIS` | Discard item | inventory menu |
| `UNQ` | Unequip item | inventory menu |
| `T01`-`T28` | Train skill N | training form (one per skill) |
| `TRO` | Transform/morph | polymorph form (GM) |
| `TEL` | Teleport (GM) | gmtool |
| `TGM` | Toggle GM mode | gmtool |
| `BAN` | Ban player (GM) | gmtool |
| `CRE` | Create NPC (GM) | gmtool |
| `GVG` | Give gold (GM) | gmtool |
| `HAI` | Set NPC hail (GM) | gmtool |
| `IMM`/`MMM` | Immortal toggle (GM) | gmtool |
| `NAA` | Set NPC name (GM) | gmtool |
| `RET` | Return/recall (GM) | gmtool |
| `QUE` | Open GM queue | gmtool |
| `GIL` | Give item to player (GM) | gmtool |
| `BOE` | Broadcast message (GM) | gmtool |
| `CH1`-`CH4` | Change char properties (GM) | gmtool |
| `;` | Say (text) | SendTxt_KeyUp |
| `-` | Shout (text) | SendTxt_KeyUp |
| `:` | Emote (text) | SendTxt_KeyUp |
| `\` | Whisper (text) | SendTxt_KeyUp |
| `'` | Clan chat (text) | SendTxt_KeyUp |
| `^` | GM help request | gmcall form |
| `/` commands | Slash commands (raw text) | SendTxt_KeyUp |

### Font Type Constants
| Constant | Value | Use |
|----------|-------|-----|
| FONTTYPE_TALK | ~255~255~255~0 | Normal chat (white) |
| FONTTYPE_FIGHT | ~255~0~0~1~0 | Combat messages (red bold) |
| FONTTYPE_WARNING | ~255~0~0~1~1 | Warnings (red bold italic) |
| FONTTYPE_INFO | ~0~255~0~0 | Info messages (green) |
| FONTTYPE_SKILLINFO | ~0~0~255~0 | Skill messages (blue) |

---

## Deities

| Deity | Domain | Notes |
|-------|--------|-------|
| Hyliios | Love, peace | Loving, supportive, no enemies |
| Bendarr | War, evil | Wants struggle and blood. Dark Elves worship him. |
| Griigo | Logic, wisdom | Senile old man, but other gods seek his advice |
| Veega | Birth, death | Balance. Can give and take. Respected by all deities. |
| Zeendic | Work, commerce | Superficial, will betray for gain |

---

## Sound Constants

60 sound effects defined (SOUND_BUMP through SOUND_BEE). Key ones:
- Combat: SOUND_SWORDSWING (34), SOUND_SWORDHIT (35/36), SOUND_MALEHURT (20/21), SOUND_FEMALESCREAM (15)
- Crafting: SOUND_CHOPPING (40), SOUND_SAW (26), SOUND_HAMMERING (17), SOUND_SMITHING (28), SOUND_FOLDCLOTHING (12)
- Magic: SOUND_SPELLEFFECT1-6, SOUND_FIREBALL (10/11)
- Ambient: SOUND_FORRESTLOOP (13/14), SOUND_SHORE (27), SOUND_BIRDS (44/59), SOUND_WINDLOOP (37), SOUND_SWAMPLOOP (33)
- Music: 32 MIDI files (mid1.mid through mid32.mid) + Undead.mp3

---

## Lore Summary

The world has passed through six ages:
1. **Age of Creation** (before recorded time) - Zeberai creates Menath and all races
2. **Age of Demons** (1st Era - 2nd Era) - Seven demons unleash evil via the Great Pentagram on the Elven continent
3. **Age of Ruins** (2nd Era - 2nd Era year 425) - Post-demon devastation
4. **Age of Revolution** (2nd Era 495 - 3rd Era) - Elvadore Elburen and Grell Gideon unite all races (including trolls) into one empire
5. **Age of War** (3rd Era - 4th Era) - Dark Elves under Kenorath Kadoxx wage war, Elvadore is executed, but his sacrifice rallies the empire to victory
6. **Age of Kings** (4th Era) - Current era. Kingdoms reformed, clans forming, economy rebuilding. The player's era.
