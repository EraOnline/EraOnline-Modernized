# Architecture

Settled technical decisions for the Era Online C# rewrite. Each decision includes rationale and what was considered but rejected. Update this document only when making new architectural decisions.

## Tech Stack

**Server: ASP.NET Core**
- Hosts the game server, SignalR hub, and serves the Blazor WASM client
- `BackgroundService` runs the game loop on a fixed tick rate
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

## Protocol Design

The original VB6 game uses a text-based TCP protocol with single-character or short-string command prefixes (e.g., "M" for move, ";" for say, "CHC" for character change). Messages are delimited by an end character (ENDC).

For the C# rewrite, we use SignalR hub methods. The protocol is defined as C# message types in the Shared library so both server and client reference the same types. We preserve the semantics of the original protocol (what information is sent when) but use proper typed messages instead of string parsing.

## Rendering Architecture

The original uses DirectDraw 4 with a custom "Grh" (Graphic) system:
- Sprite sheets (BMP files) containing multiple sprites
- `Grh.dat` / `Grh.ini` define where each sprite lives in which sheet, its dimensions, and animation info (frames, speed)
- Characters are composited: body (with walk animation) + head (directional) + weapon animation + shield animation
- Map tiles have 3 layers: ground, fringe, top
- Viewport is 20x11 tiles at 32x32 pixels each, with an 80px offset from the window edge

The C# client replicates this with:
- A TypeScript rendering module that drives an HTML5 Canvas
- The same Grh data format, parsed and loaded into Canvas-compatible image sources
- Sprite compositing and animation matching the original's approach
- Blazor calls into the TS module via JS interop for game state updates

## Deployment

Single Azure App Service instance (Linux). The Server project is the deployable unit, hosting both the API/SignalR hub and the Blazor WASM static files. Persistence backend (CosmosDB or Blob Storage) is the only external dependency.
