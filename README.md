# Era Online (Modernized)

A C# rewrite of **Era Online**, a 1999 2D MMORPG built in Visual Basic 6 by Erling Ellingsen and friends in Norway. Ported in spring 2026 with [Claude Code](https://claude.com/claude-code).

This repo is a public snapshot of the port through 2026-04-20. Presented at *Code with Claude: Extended* in San Francisco on May 7, 2026.

## About the original

Era Online ran from 1999 to ~2001 with an active community of 30-40 players and an IRC channel on Undernet. Erling later released the source, art, and music as freeware. The world of Menath, the artwork, the gossip, the spell names, the lore — all of that is his.

Original sources are preserved in `src_vb6/`. Original web archives, manuals, and screenshots are in `docs_vb6/`.

## Build & run

```bash
dotnet build EraOnline.sln
dotnet run --project src/Server
```

The server loads game data from `src/Client.Web/wwwroot/data/`. For project structure and development conventions, see `CLAUDE.md`.

## License

Erling's original sources, art, and music are freeware per his redistribution terms (`src_vb6/README.txt`). The C# rewrite is offered in the same spirit — use it, modify it, redistribute it; please credit the original.
