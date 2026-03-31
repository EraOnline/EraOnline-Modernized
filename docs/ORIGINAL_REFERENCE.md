# Original Game Reference

Distilled reference of how Era Online (VB6, ~1999-2000) works, derived from source code analysis. Organized by system for easy lookup during implementation. When in doubt, consult the original VB6 source in `src_vb6/`.

Key server files: `ServerLogic.bas` / `GameLogic.bas` (~7K lines each), `TCP.bas` / `Networking.bas` (~3.2K lines each, largely duplicated), `Declarations.bas` (data types), `FileIO.bas` (data loading), `Checks.bas`, `General.bas`.

Key client files: `frmMain.frm` (main game form), `TCP.bas` (networking + client HandleData), `Declares.bas` (client data types), `Graphics.bas` (DirectDraw rendering), `General.bas` (game loop, map loading), `Sound.bas`.

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

### Hit Calculation
- Attacker's **swordmanship** skill determines chance to hit
- Defender's **tactics** skill determines chance to dodge
- If hit lands: damage = random(MinHIT, MaxHIT) from weapon + base stats, reduced by defender's DEF (from armor/shields + parrying skill)

### PvP Rules
- Players under level 5 cannot attack or be attacked by players over level 5
- Attacking a non-criminal, non-dueling player makes you a criminal
- /DUEL for consensual PvP (no criminal flag)
- PKFREEZONE maps disable all PvP

### NPC Combat
- Hostile NPCs detect nearby players and chase/attack
- NPCs won't attack players who are "too experienced" for them (prevents high-level players being chased by spiderlings)
- When attacked, NPCs fight back
- Guards specifically chase criminals

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

### Rank Titles
Based on overall rep, players get titles like "The Dreaded", "The Hated", "The Respected", "The Beloved", etc. These appear in the player's name when clicked.

### Effects
- NPCs may refuse to trade if reputation is too low
- Killing players has "harder reputation punishment"

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

### Key Server->Client Messages
| Prefix | Meaning |
|--------|---------|
| `@` | Chat/info message (followed by text + font type) |
| `!!` | Error/disconnect message |
| `CHC` | Character change (charindex, body, head, heading, weapon, shield) |
| `SUP` | Set user position (x, y) |
| `DEA` | Player died |
| `TEN` | Near campfire (trigger healing) |
| `PLW` | Play sound (sound constant) |
| `PL3` | Play sound effect (variant) |
| `PC2` | Update weapon equipment slot |
| `PIC` | Update clothing equipment slot |
| `PC3` | Update shield equipment slot |
| `PC4` | Update head equipment slot |
| `AT1` | Start action timer (progress bar) |

### Key Client->Server Messages
| Prefix | Meaning |
|--------|---------|
| `LOGIN` | Log in existing character (fields separated by comma/char 44) |
| `NLOGIN` | Create new character |
| `ERASE` | Delete character |
| `QIT` | Quit |
| `M` | Move (followed by direction: 1=N, 2=E, 3=S, 4=W) |
| `LC` | Left click (x, y coordinates) |
| `BTL` | Toggle battle mode |
| `AT4` | Flag NPC as attackable |
| `COO` | Consider target (TAB key) |
| `UPS` | Update spell book request |
| `UCS` | Update character sheet request |
| `CHP` | Chop tree |
| `FSH` | Fish |
| `MIN` | Mine |
| `CMP` | Camp fire heal |
| `BOO` | Message board request |
| `YUP` | Post message |
| `HHH` | Hide |
| `UHD` | Unhide |
| `DGU` | Disguise |
| `UGU` | Undisguise |
| `WRI` | Write sign |
| `RPU` | Request position update |
| `;` | Say (followed by text) |
| `-` | Shout (followed by text) |
| `:` | Emote (followed by text) |
| `\` | Whisper (followed by text) |
| `^` | GM help request |
| `/` commands | Slash commands sent as raw text |

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
