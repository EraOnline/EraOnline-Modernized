# Architecture

Settled technical decisions for the Era Online C# rewrite. Each decision includes rationale and what was considered but rejected. Update this document only when making new architectural decisions.

## Tech Stack

**Server: ASP.NET Core**
- Hosts the game server, SignalR hub, and serves the Blazor WASM client
- `BackgroundService` runs the game loop at **50ms tick rate** (matching the original's `GameTimer.Interval = 50`). Each tick processes: NPC AI, idle detection, world state updates.
- Separate timer-driven systems at their original intervals: NPC attack processing (4000ms), weather (dynamic)
- All game state lives in memory, just like the original VB6 server
- Single process, single instance - deployed to one Azure App Service node

*Why not a dedicated game server framework (DarkRift, LiteNetLib)?* The original game's scale is ~30-40 concurrent users. ASP.NET Core is more than capable and keeps the stack unified.

**Networking: SignalR**
- WebSocket transport with automatic fallbacks
- Works cleanly with both Blazor WASM and .NET console clients
- Provides RPC semantics over the connection

*Why not raw WebSockets?* SignalR handles reconnection, serialization, and transport negotiation. Minor overhead is irrelevant at this scale. *Why not raw TCP like the original?* Browsers can't do raw TCP. We'd need separate protocol paths for web vs. native clients.

**Web Client: Blazor WebAssembly**
- Hosted by the Server project (single deployment unit)
- HTML5 Canvas for the game viewport, driven via JS/TS interop
- Razor components for all UI panels (inventory, skills, spells, trading, chat, etc.)
- The game UI is heavily form-based (dialogs, lists, stat displays) which suits Blazor's component model

*Why Canvas via JS interop instead of pure Blazor rendering?* The game viewport needs a `requestAnimationFrame` render loop with sprite blitting. This is fundamentally a Canvas/WebGL operation. Blazor's component model isn't designed for real-time game rendering. However, everything *around* the viewport (inventory, character sheet, skill book, chat) is classic UI that Blazor handles well.

*Why not a pure TypeScript SPA?* Loses C# code sharing between client and server. Kyle's primary expertise is Blazor WASM.

*Why not a game engine (Godot, MonoGame)?* Godot has web export but is a different ecosystem. MonoGame has no web story. Both are overkill for what is fundamentally a simple 2D tile renderer.

**CLI Client: .NET Console Application**
- For LLM interaction (text commands in, text descriptions + optional screenshots out)
- Same SignalR client, same Shared library
- Generates textual descriptions of the game state deterministically

**Persistence: TBD (CosmosDB likely)**
- The original game keeps everything in memory and persists to flat INI files on save/login/logout
- SQLite doesn't work well on Azure App Service (the /home directory is network-mounted Azure Files via SMB, which causes file locking issues with SQLite)
- CosmosDB serverless is cheap at low scale and Kyle has extensive experience with it
- Azure Blob Storage (one JSON blob per character, like the original's one .chr file per character) is also viable
- We'll define an `IGameRepository` interface so the backend can be swapped

*Decision deferred until we start implementing persistence. The game data files (OBJ.dat, NPC.dat, maps, etc.) are read-only and will be loaded from static files or embedded resources regardless of the persistence backend.*

**Map Editor: Mode of Client.Web**
- Not a separate application. Toggle/mode within the web client.
- Avoids maintaining multiple web frontends
- The original had a standalone MapEditor VB6 project; we consolidate into one client

## Project Structure

```
EraOnline.sln
src/
  Shared/          Shared library (data models, constants, protocol)
  Server/          ASP.NET Core host (game logic, SignalR hub, persistence)
  Client.Web/      Blazor WASM (rendering, UI, Canvas interop)
  Client.CLI/      Console client (text-based, for LLMs)
```

The Server project hosts the Client.Web Blazor WASM app. Single deployment artifact. Runs on a single Azure App Service instance.

## Client Timer Architecture

The original client uses 12 VB6 Timer controls on frmMain to drive game subsystems. In the C# rewrite, these become either server-driven tick events (pushed via SignalR) or client-side JS timers, depending on whether they need server authority.

**Server-authoritative timers** (move to server game loop):
- Attack cooldown (4000ms) - server controls swing rate
- NPC attack enable (4000ms) - server controls NPC combat cadence
- Criminal countdown (60000ms) - server tracks criminal timer
- Campfire healing (10000ms) - server applies HP regen
- Meditation (10000ms) - server applies mana regen
- Eat/Drink auto-consumption (15000ms) - server applies food/drink healing
- Skill progress (5000ms) - server advances crafting progress bars

**Client-side timers** (stay on client):
- FPS counter (1000ms) - display only
- Ambient bird sounds (10000ms) - client audio
- Thunder sounds (20000ms) - client audio during rain
- Rain damage check (30000ms) - client sends STA message, server validates
- Input polling (900ms) - client UI responsiveness

## Protocol Design

The original VB6 game uses a text-based TCP protocol with 120+ unique message prefixes (auto-detected by `vb6-ast query --protocol`). Messages are delimited by Chr(1) (ENDC).

For the C# rewrite, we use SignalR hub methods. The protocol is defined as C# message types in the Shared library so both server and client reference the same types. We preserve the semantics of the original protocol (what information is sent when) but use proper typed messages instead of string parsing. The full original protocol map is available via the vb6-ast tool.

## Rendering Architecture

The original uses DirectDraw 4 with a custom "Grh" (Graphic) system:
- Sprite sheets (BMP files) containing multiple sprites
- `Grh.dat` / `Grh.ini` define where each sprite lives in which sheet, its dimensions, and animation info (frames, speed)
- Characters are composited: body (with walk animation) + head (directional) + weapon animation + shield animation
- Map tiles have 3 layers: ground, fringe, top
- Viewport is 20x11 tiles at 32x32 pixels each, with an 80px offset from the window edge

The original renderer (`RenderScreen` in Graphics.bas) uses a **3-pass approach**:
1. Ground layer - opaque blit of `graphic(1)` for all visible tiles
2. Transparent layers - fringe `graphic(2)`, objects, weather `graphic(3)` with color-key transparency (black = transparent)
3. Characters - composited as Head + Body + Shield + Weapon, each with 4-directional walk animations

Character movement is interpolated at **8 pixels per frame** toward the target tile position, giving smooth walking between the 32px tiles.

The C# client replicates this with:
- A TypeScript rendering module that drives an HTML5 Canvas
- The same Grh data format, parsed and loaded into Canvas-compatible image sources
- The same 3-pass rendering with the same compositing order
- 8px/frame movement interpolation matching the original
- Blazor calls into the TS module via JS interop for game state updates

## Deployment

Single Azure App Service instance (Linux). The Server project is the deployable unit, hosting both the API/SignalR hub and the Blazor WASM static files. Persistence backend (CosmosDB or Blob Storage) is the only external dependency.
