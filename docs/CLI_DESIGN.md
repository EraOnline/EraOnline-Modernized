# Era Online CLI — Design Plan

A command-line client for Era Online designed for LLM players (and human text-mode players). Two-process architecture: a persistent daemon holds the SignalR connection, and a short-lived command tool sends commands and receives responses.

## Principles

1. **The server treats all clients the same.** The CLI implements the SignalR client contract identically to the web client. No special endpoints, no LLM flags.
2. **World knowledge is earned per character.** You only know about maps you've visited. Each character has their own knowledge base, persisted to disk.
3. **Headless rendering produces real PNGs.** A C# port of the 3-pass renderer using SkiaSharp, giving the LLM actual visual context.
4. **The CLI is a proper installed tool.** XDG-compliant installation, `eraonline` on PATH.

## Installation

`tools/publish-cli.sh` (Linux/macOS) and `tools/publish-cli.ps1` (Windows):
- Builds self-contained binary
- Installs to `~/.local/bin/eraonline` (Linux/macOS) or `%LOCALAPPDATA%\EraOnline\eraonline.exe` (Windows)
- Copies game data (sprite PNGs, GRH definitions, object/NPC/map JSON) to `~/.local/share/eraonline/data/`

## Configuration & Storage

```
~/.config/eraonline/
  config.json                    # machine-level: server URL, IPC port (default 19999)

~/.local/share/eraonline/
  data/                          # game data (sprites, JSON — copied at install)
    grh.json, objects.json, npcs.json, heads.json, bodies.json, ...
    grh/                         # sprite sheet PNGs
    maps/                        # map JSON files
  characters/
    Claude/                      # per-character knowledge
      knowledge.json             # overworld graph, explored maps, discovered spaces
      journal.md                 # session journal entries
      screenshots/               # viewport PNGs, timestamped
    Merchant_Haiku/
      knowledge.json
      journal.md
      screenshots/
```

## Two-Process Architecture

### Process 1: Session daemon — `eraonline start --name Claude --password secret`

- Connects to server via SignalR (URL from config.json)
- Logs in to existing character
- Maintains live `GameState` from server events (position, map, characters, inventory, stats, chat, weather, etc.)
- Maintains `WorldKnowledge` — updated as you explore, persisted to `knowledge.json`
- Loads headless renderer (sprite sheets, GRH defs) for on-demand PNG generation
- Listens on TCP localhost:19999 for commands from the command client
- On each command: execute, wait for server events to settle (~200ms), return timestamped text response
- On `stop`: save knowledge, disconnect

### Process 2: Command client — `eraonline <command> [args]`

- Connects to daemon's TCP socket
- Sends command, reads response, prints it, exits
- If daemon isn't running, prints error with hint to run `eraonline start`

## World Knowledge (per character, persisted)

```json
{
  "overworld": {
    "81": {
      "name": "Castlefall",
      "exits": {"north": 79, "east": 82, "south": 84, "west": 80},
      "tileExits": [{"x": 55, "y": 30, "toMap": 142}]
    }
  },
  "maps": {
    "81": {
      "visitCount": 5,
      "lastVisit": "2026-04-12T14:30:00Z",
      "spaces": [
        {"name": "Blacksmith", "x": 25, "y": 30, "type": "npc", "auto": true},
        {"name": "Tavern", "x": 35, "y": 20, "type": "manual"}
      ],
      "npcsFound": ["Guard Captain", "Blacksmith", "Wodyr The Wise"],
      "notes": "",
      "screenshots": ["20260412-143500.png"]
    }
  }
}
```

**When you enter a new map for the first time:**
1. Map gets added to the overworld graph with its edge exit connections
2. NPC positions on the map are recorded as auto-detected spaces (named by NPC name)
3. Tile exits are recorded (named by destination map if known, or "Door/Stairs" if not)
4. Any tile exit destinations are noted but NOT explored — you only know "there's a door here leading to Map 142" until you walk through it

**The overworld graph** enables macro-navigation: "I know Castlefall connects north to Map 79 which connects north to Map 80 which is Angelmoor." Routing across the graph gives you multi-map pathfinding through explored territory.

## Journal (per character, persisted)

Appended to `characters/<name>/journal.md`. Written by the LLM, not auto-generated. Two mechanisms:

- `eraonline journal write "<entry>"` — append a timestamped entry anytime
- `eraonline journal read` — read journal entries (for context recovery across sessions)

## Headless Renderer

C# port of the 3-pass renderer using SkiaSharp. Produces static PNG snapshots.

**Input:** Map data + character positions + camera position (centered on player)
**Output:** PNG file saved to `characters/<name>/screenshots/<yyyymmdd-hhmmss>.png`

**Rendering passes (matching VB6/JS exactly):**
1. Ground — opaque blit of `graphic[0]` for each visible tile
2. Fringe — transparent blit of `graphic[1]` (trees, buildings, walls) with black→alpha transparency
3. Ground objects — item GRHs at tile positions
4. Characters — composited head + body + weapon + shield, directional sprites
5. Alpha reveal — three-buffer compositing with radial gradient around player, so you can see through overlapping fringe sprites

**Viewport:** 20x11 tiles (matching original), or optionally full map render.

**What it loads at startup:**
- Sprite sheet PNGs from data directory
- GRH definitions from grh.json
- Head/body/weapon/shield anim definitions

**Invocation:**
```bash
eraonline screenshot     # renders viewport PNG, returns filename
```

The screenshots directory doubles as a visual log. Spaces log entries reference screenshot filenames for cross-referencing.

## Command Set

### Session management
```
eraonline start --name <name> --password <pw>  # start daemon, connect, login
eraonline stop                                  # save, disconnect, stop daemon
```

### Observation
```
eraonline look                    # tactical: nearby entities, ground, spaces, status
eraonline look at <name>          # inspect/target a nearby entity (left-click equivalent)
eraonline screenshot              # render viewport to PNG, return filename
eraonline map                     # current map overview: all known spaces, connections
eraonline overworld               # show known map graph (explored territory)
```

### Navigation
```
eraonline n / s / e / w           # single tile movement
eraonline turn left / right       # rotate in place
eraonline move <space-name>       # A* pathfind to named location on current map
eraonline move to <x> <y>         # A* pathfind to coordinates
eraonline route <map-name>        # plan & execute multi-map route via overworld graph
```

Auto-movement is interrupted (stopped) if:
- The character receives a chat message directed at them
- The character takes damage (attacked)
- The path is blocked (can't reach destination)

On interruption, the command returns with the events that caused the stop, and the character's current position. The LLM decides what to do next.

### Await (blocking with triggers)
```
eraonline await <seconds>                 # wait, return all events
eraonline await <seconds> --until chat    # return early on chat
eraonline await <seconds> --until combat  # return early on damage/death
eraonline await <seconds> --until player  # return early on player entering area
eraonline await <seconds> --until arrival # return early when pathfinding completes
eraonline await <seconds> --until craft   # return early when crafting finishes
eraonline await <seconds> --until any     # return on any event
```

### Combat
```
eraonline battle                  # toggle battle mode
eraonline attack                  # swing weapon
eraonline consider                # evaluate current target
eraonline target <name>           # target a nearby entity
```

### Chat
```
eraonline say <message>           # local
eraonline shout <message>         # map-wide
eraonline emote <action>          # emote
eraonline whisper <name> <msg>    # private message
```

### Slash commands (pass-through to server via Say)
```
eraonline /hail                   # NPC dialogue
eraonline /gossip                 # NPC gossip
eraonline /meditate               # toggle meditation
eraonline /trade                  # open NPC trade
eraonline /train                  # open training
eraonline /heal                   # NPC healing
eraonline /deposit <amount>       # banking
eraonline /withdraw <amount>
eraonline /balance
eraonline /who                    # online players
eraonline /stats                  # detailed stats
eraonline /save                   # save character
eraonline /duel                   # toggle PvP consent
```

### Inventory (read list first, then act by slot number)
```
eraonline inventory               # list all items with slot numbers
eraonline use <slot>              # use item in slot
eraonline drop <slot> [amount]    # drop item
eraonline get                     # pick up from ground
```

### Trading
```
eraonline buy <slot>              # buy from NPC (after /trade)
eraonline sell <slot>             # sell to NPC
```

### Training
```
eraonline train <slot>            # train skill (after /train shows list)
```

### Magic
```
eraonline spells                  # list spell book with slot numbers
eraonline cast <slot>             # cast spell
```

### Gathering
```
eraonline fish / mine / chop      # gather resources (needs tool equipped, tile nearby)
```

### Spaces
```
eraonline spaces list             # list known spaces on current map
eraonline spaces define <name> <x> <y>  # name a location
eraonline spaces remove <name>    # remove a space definition
```

### Journal & Knowledge
```
eraonline journal read            # read recent journal entries
eraonline journal write "<text>"  # append journal entry
eraonline events                  # show recent events without acting
eraonline help                    # list commands
```

## Output Format

Every command returns timestamped output with a status line:

```
[14:32:01.200] Kyle says: Hey Claude!
[14:32:03.800] a snake moves to (62,41).
[14:32:05.000] You walk north to (59,40).
──
[14:32:05] Castlefall (59,40) N | HP 45/45 | STA 30/30 | MAN 150/150 | Gold 250 | Battle:Off
```

Events that accumulated since the last command appear first. Then the result of the current command. Then the status line (always present, always last).

The `look` command gets a richer block:

```
[14:35:10] ═══ Castlefall (59,40) facing North ═══
HP 45/45 | STA 30/30 | MAN 150/150 | Gold 250 | Weather: Clear

Nearby:
  Guard Captain [guard] — 2 tiles north
  Kyle the Paladin [player] — 1 tile south
  a snake [hostile] — 3 tiles east

Ground: Rusty Dagger (at your feet)

Spaces: Town Square (5 SW), Blacksmith (15 W), North Gate (34 N → Map 79)
```

The `map` command shows the full explored map:

```
[14:35:15] ═══ Castlefall (Map 81) ═══
You are at (59,40). Visited 5 times.

Known spaces:
  Blacksmith (25,30) ......... 15 tiles W
  Guard Captain (45,38) ...... 14 tiles W
  Priest of Life (22,60) ..... 28 tiles SW
  North Gate ................. 34 tiles N  → Map 79 (Angelmoor Road)
  East Gate .................. 33 tiles E  → Map 82

Players here: Kyle (1 S)
```

## Pathfinding

### Single-map
A* on the map's blocked tile array (100x100). NPC positions treated as passable (they move). When `move Blacksmith` is issued:

1. Look up "Blacksmith" → (25, 30) in current map's spaces
2. Run A* from current position
3. Send `Move()` calls along the path with ~350ms pacing
4. Accumulate all events during the walk
5. Return when arrived, or return early if interrupted (attacked, messaged, blocked)

### Cross-map
`route Angelmoor` uses the overworld graph (BFS on known map connections):

1. Find path through explored maps: 81→79→80→Angelmoor
2. For each map: pathfind to the exit leading to the next map
3. Cross zone boundary (server handles the warp)
4. Continue on next map
5. Return when arrived or when path fails (unexplored territory, blocked)

If the route passes through unexplored maps, it stops at the boundary and reports.

## Implementation Structure

```
src/Client.CLI/
  Program.cs                          — entry point, arg dispatch
  Configuration.cs                    — config.json, XDG paths, character data paths
  Session/
    GameSession.cs                    — SignalR connection, event handlers, IPC server
    GameState.cs                      — live game state from server events
    WorldKnowledge.cs                 — per-character persistent knowledge
    Journal.cs                        — per-character journal read/write
  Navigation/
    Pathfinder.cs                     — A* on map tile grid
    SpaceDetector.cs                  — auto-detect spaces from NPC/exit data
    OverworldRouter.cs                — multi-map routing via knowledge graph
  Rendering/
    HeadlessRenderer.cs               — 3-pass C# renderer, PNG output via SkiaSharp
    SpriteLoader.cs                   — sprite sheet + GRH + anim def loading
  Commands/
    CommandRouter.cs                  — parse command string, dispatch to handler
    CommandFormatter.cs               — timestamps, status line, output formatting
  IPC/
    IpcServer.cs                      — TCP listener in daemon process
    IpcClient.cs                      — TCP client in command process

tools/
  publish-cli.sh                      — Linux/macOS build + XDG install
  publish-cli.ps1                     — Windows build + install
```

## Implementation Order

1. **Minimum viable connection**: start daemon, connect via SignalR, login, move one tile, send chat message. Text-only output. Enough to verify the connection works with a human watching in the web client.
2. **Headless renderer**: port JS renderer to C#, screenshot command. Now the LLM can see.
3. **Core commands**: look, inventory, stats, combat (battle/attack/consider), all slash commands.
4. **World knowledge**: per-character persistence, space detection on map entry, overworld graph.
5. **Navigation**: A* pathfinding, `move <space>`, cross-map routing.
6. **Await mode**: blocking commands with triggers.
7. **Journal**: read/write, session continuity.
8. **Polish**: publish scripts, help text, error handling.
