# Era Online

C# rewrite of the ~1999 VB6 2D MMORPG "Era Online" by Erling Ellingsen (Norway).
Original VB6 source in `src_vb6/`, original website/docs in `docs_vb6/`.

## Getting Oriented

Read these in order:

1. **CLAUDE.md (you are here)** - build/run commands, project structure, conventions
2. **docs/PROGRESS.md** - master checklist, current phase, overall status
3. **Most recent docs/logs/ entry** - what happened last session, handoff notes
4. **Most recent docs/journal/ entry** - reflections, project context, collaboration notes
5. **docs/ARCHITECTURE.md** - settled technical decisions and rationale
6. **docs/ORIGINAL_REFERENCE.md** - how the original VB6 game works (our implementation spec)

Also explore the original VB6 source in `src_vb6/` and the original website/manual in `docs_vb6/` to build your own understanding of the game. The original screenshots in `docs_vb6/screenshots/` and `docs_vb6/images/` are worth looking at. The manual tutorial images in `docs_vb6/manual/beginner_files/` show the original UI.

If the user hasn't told you today's date, ask for it - you'll need it for work logs and journal entries.

## Status Report

When Kyle asks for the status report (typically at session start), run `tools/vb6-ast/bin/vb6-ast stats` and render a visual dashboard. The format:

```
Era Online — Status Report
══════════════════════════════════════════════════════
Phase 3 of 7: Client-Server Connection

Functions  ████░░░░░░░░░░░░░░░░░░░░░░░░░░  63/704   9%
Types      ████████████████░░░░░░░░░░░░░░  16/53   30%
Constants  ████████░░░░░░░░░░░░░░░░░░░░░░  157/548  29%
Globals    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   0/305   0%
──────────────────────────────────────────────────────
Overall    ████░░░░░░░░░░░░░░░░░░░░░░░░░░  236/1610 15%

Partial: 5 fns (HandleData server+client, Main, GameTimer, SaveUser)
Sections: 10 ported across 2 partial functions

Server coverage:      28/101 fns   Client coverage:      35/448 fns
Skipped: 103 (62 duplicate fns, 29 types, 7 consts, 5 DirectDraw fns)
```

How to build the chart:
- **Denominators** = total minus skipped (the actionable remaining). Calculate from the stats output.
- **Bar width** = 30 characters. Fill = `█`, empty = `░`. Chars filled = round(ported / denominator * 30).
- **Phase** = read the first line of docs/PROGRESS.md "Current State" section.
- **Partial** = list the function names with "partial" status (from `vb6-ast query --status partial`).
- **Server/Client split** = count ported functions in Server/* vs Client/* modules.

Also show a one-line summary of what was done last session (from the most recent log) and what's next (from PROGRESS.md).

## Keeping Annotations Current

After implementing VB6 functionality, update the vb6-ast annotations before committing:

```bash
# Mark a function as ported with its target location
tools/vb6-ast/bin/vb6-ast annotate Server/GameLogic:UserDie --status ported --target "Server/Combat.cs:UserDie"

# For large router functions, use sections to track individual branches
tools/vb6-ast/bin/vb6-ast annotate Server/TCP:HandleData --section ";" --status ported --target "Server/Hubs/GameHub.cs:Say"

# For functions that are partially done
tools/vb6-ast/bin/vb6-ast annotate Server/frmMain:GameTimer_Timer --status partial --note "NPC AI not yet"

# Target can point to any file: C#, JS, or tools
tools/vb6-ast/bin/vb6-ast annotate Client/Graphics:RenderScreen --status ported --target "Client.Web/wwwroot/js/renderer.js:render"
```

Valid statuses: `not-started`, `in-progress`, `ported`, `partial`, `skipped`. Include annotation updates in the same commit as the implementation they track.

## Tools

**vb6-ast** - VB6 source code analyzer at `tools/vb6-ast/`. Parses all 89 VB6 source files using ANTLR4, extracts declarations, auto-detects call graph and protocol messages. Use it to look up any VB6 function, type, constant, form control, or protocol message.

```bash
bash tools/vb6-ast/publish.sh                            # Build (first time)
tools/vb6-ast/bin/vb6-ast stats                          # Porting progress
tools/vb6-ast/bin/vb6-ast show Server/GameLogic:UserDie  # Look up a function
tools/vb6-ast/bin/vb6-ast list controls --module Client/frmMain  # Timer controls
tools/vb6-ast/bin/vb6-ast query --protocol               # Full protocol map
tools/vb6-ast/bin/vb6-ast query --calls UserDie           # Who calls this?
tools/vb6-ast/bin/vb6-ast annotate Server/GameLogic:Foo --status ported --target "Server/Combat.cs:Foo"
```

**eo-data-converter** - Converts all original VB6 game data files to JSON at `tools/eo-data-converter/`. Parses both INI-format files (OBJ.dat, NPC.dat, Spells.dat, Head.dat, Body.dat, etc.) and binary files (Grh.dat, map .map/.inf files). Output in `tools/eo-data-converter/data/`.

```bash
bash tools/eo-data-converter/publish.sh                   # Build (first time)
tools/eo-data-converter/bin/eo-data-converter              # Run (converts all data)
# Output: data/objects.json, npcs.json, spells.json, config.json, grh.json, maps/map-NNN.json, etc.
```

## Build & Run

```bash
dotnet build EraOnline.sln                   # Build all projects
dotnet run --project src/Server              # Run server (loads game data, starts game loop, listens on port 5000)
```

The server loads game data from `tools/eo-data-converter/data/` on startup. If the JSON data files don't exist, run `bash tools/eo-data-converter/publish.sh && tools/eo-data-converter/bin/eo-data-converter` first. The Blazor WASM client requires the `wasm-tools` workload: `dotnet workload install wasm-tools`.

## Project Structure

```
EraOnline.sln
src/
  Shared/          Data models, constants, protocol messages
  Server/          ASP.NET Core, SignalR hub, game loop, persistence
  Client.Web/      Blazor WASM, Canvas rendering, game UI
  Client.CLI/      Console client for LLM interaction
src_vb6/           Original VB6 source (Client, Server, MapEditor, GameData)
docs_vb6/          Original website, manual, screenshots, music
docs/              Project documentation
  ARCHITECTURE.md  Technical decisions
  PROGRESS.md      Master checklist and status
  ORIGINAL_REFERENCE.md  Original game behavior spec
  logs/            Daily work logs
  journal/         Claude's reflective journal
```

## Conventions

*Will be established as we write code. Examples: naming patterns, how protocol messages are structured, how we handle the Grh sprite system, etc.*

## Key Principles

- **Faithful port first.** Implement the game as close to the original as possible. Don't redesign game mechanics during the port. Fix obvious bugs along the way, but resist the urge to "improve" things until the port is complete and running.
- **Original assets.** Use the original art, sounds, and music. Original 32x32 tile resolution. No upscaling or re-rendering for now.
- **The VB6 source is the spec.** When in doubt about how something should work, read the original code. `docs/ORIGINAL_REFERENCE.md` is a distilled version, but the VB6 source is authoritative.
