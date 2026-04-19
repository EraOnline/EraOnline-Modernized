# CLI Events Redesign

Design note for fixing event delivery in the CLI client. Written after a play session on 2026-04-18 where chat from another player went silent on my side mid-session while combat and movement broadcasts kept arriving.

## What we observed

During a multi-map play session as Sage:

- Chat from Yo-Ho arrived normally on Map 80.
- I crossed to Map 79. The first chat from Yo-Ho on Map 79 ("important: we need to go up a bit...") arrived.
- Every Yo-Ho chat after that was lost on my side. He kept saying things — "nice!", "you have to aggro the bats and spiders", "let's stop here for now", several whispers, two shouts — none of them appeared in any of my CLI command responses.
- Yo-Ho's `MoveChar` updates kept arriving (I could see his position in the ASCII map). My own `Stats` updates kept arriving (HP, gold, EXP all ticked correctly through the lost interval). Weather updates arrived (status line flipped from Clear to Rain even though the "It begins to rain." event itself did not appear).
- My own outbound `say` continued to work — Yo-Ho saw all of my messages.
- Combat strike/miss text from the server was unreliable from the start of the session (sometimes appeared, mostly didn't), but combat itself was working — kills landed, gold and EXP advanced.

## Root cause

`GameState.AddEvent` and `GameState.GetNewEvents` in `src/Client.CLI/Session/GameState.cs` use an absolute index into a list that is trimmed in place:

```csharp
public void AddEvent(string text)
{
    lock (RecentEvents)
    {
        RecentEvents.Add(new TimestampedEvent(DateTime.Now, text));
        if (RecentEvents.Count > 200)
            RecentEvents.RemoveRange(0, RecentEvents.Count - 200); // trims FRONT
    }
}

public List<TimestampedEvent> GetNewEvents()
{
    lock (RecentEvents)
    {
        var newEvents = RecentEvents.Skip(_lastReportedEventIndex).ToList();
        _lastReportedEventIndex = RecentEvents.Count; // absolute
        return newEvents;
    }
}
```

`_lastReportedEventIndex` is treated as an absolute position in the list. `RemoveRange(0, ...)` shifts every remaining element down, so after one trim the index points past `RecentEvents.Count`. From then on `Skip(_lastReportedEventIndex)` returns an empty enumerable, the index gets overwritten with the new (smaller) `Count`, and every subsequent event is silently dropped at read time.

A combat-heavy session crosses 200 events fast (each strike, miss, NPC swing, skill-up, kill notice, loot pickup, gold-found, rep change is its own `Chat`/event). Once the buffer trims, all chat from that point onward is lost — but state-only handlers (`OnMoveChar`, `OnStats`, `OnWeather`'s flag flip) bypass `AddEvent` and continue to work. That matches the observed symptoms exactly.

The "important" message arrived because it landed before the trim. "nice!" landed after.

## Contributing factors

These didn't cause the silence, but they made the bug harder to spot and they hurt event fidelity in their own right.

**1. The 250 ms post-`InvokeAsync` delay in `ExecuteCommand` is too short for racy server replies.**

`Attack` returns from `InvokeAsync` as soon as the server's hub method returns. The server's strike/miss text is sent via `Clients.Caller.SendAsync("Chat", ...)` inside that method, which dispatches asynchronously. The 250 ms delay sometimes captures it, often does not. When it doesn't, the strike text arrives a few hundred ms later and gets surfaced by the next command — but if the next command is `look | head -10` the text gets discarded.

**2. Piping CLI output through `head`/`grep` discards events permanently.**

Every command that produces output calls `GetNewEvents()`, which advances the cursor. If the resulting text is then truncated or filtered downstream, those events are gone — they were marked reported but never seen by the human/LLM. This is purely an LLM-side discipline issue, but the architecture invites it because the formatted output mixes events with map/legend/status.

**3. `await --until <trigger>` consumes events even when they don't match.**

Inside `ExecuteAwait`, `lastSeenCount` is updated on every poll regardless of whether the event matched the trigger. The trailing `FormatResponse(null)` call after the await loop will then pull anything new since the await ended via `GetNewEvents()`, but events that arrived during the await and did not match the trigger were never displayed. They show up only via the AddEvent log path, not in any output. (This is a smaller leak than the trim bug, but worth fixing in the same pass.)

## Proposed redesign

Two changes that compose: a write-through event log on disk, and a Monitor-friendly tail/stream interface for async push.

### 1. Write-through event log (source of truth)

Every event the daemon receives or generates appends one line to:

```
~/.local/share/eraonline/characters/<Name>/events.log
```

Format: one event per line, JSON or pipe-delimited. Tentative pipe-delimited format for grep-friendliness:

```
2026-04-18T23:04:52.498Z|chat|Yo-Ho: important: we need to go up a bit...
2026-04-18T23:04:53.020Z|stats|hp=435 maxhp=500 sta=500 maxsta=500 gold=24
2026-04-18T23:05:43.928Z|combat|a giant snake strikes you for 1 !
2026-04-18T23:05:49.477Z|combat|You miss !
2026-04-18T23:06:23.828Z|character|a giant snake left the area.
```

Categories give downstream filters a clean grep target without parsing free-form text. Suggested categories: `chat`, `whisper`, `shout`, `emote`, `combat`, `stats`, `inventory`, `spell`, `weather`, `meditate`, `craft`, `audio`, `character`, `map`, `system`.

The log is append-only and never trimmed by the daemon. Log rotation is the user's problem (logrotate, manual, or eventually a `--max-log-size` flag). For LLM session lengths this is fine.

### 2. In-memory buffer becomes a cache, not the source of truth

Keep `RecentEvents` for fast in-process polling, but:

- Switch `_lastReportedEventIndex` to a monotonic event ID (long counter that never wraps), assigned in `AddEvent`.
- Each event carries its ID. `GetNewEvents` becomes "everything since ID > N".
- The buffer can still cap at 200 in memory; events older than that are read from disk via the log file if anyone asks.

This single change fixes the trim/index bug without any new abstractions.

### 3. New CLI commands

```
eraonline tail [N=50]               # print last N events from events.log
eraonline tail --since <id>         # print events strictly after this ID
eraonline tail --filter chat,whisper  # category filter
eraonline stream [--filter ...]     # block, print each new event as it arrives
                                     # exits on SIGINT / daemon stop
```

`stream` is the Monitor-friendly entry point. It reads the same log file with `tail -f`-style semantics inside the CLI binary so it works on Windows too without bash dependencies.

Existing commands keep working as today, but their event display can reference the log: e.g. `look` still calls `GetNewEvents()` to show what arrived between commands, but the events also exist in the log so nothing is lost if `look | head` truncates them.

### 4. Async push via the Claude harness

With `stream` available, an LLM-driven session can use the harness `Monitor` tool:

```
Monitor(
  command: "eraonline stream --filter chat,whisper,combat",
  description: "Era Online events for Sage",
  persistent: true
)
```

Each matching event becomes a notification in the conversation. Notifications don't make me real-time-reactive while the human is typing — I'm not running between turns — but they ensure that on my next turn I see everything that happened in the gap, instead of polling and hoping nothing fell through. Filter selection per session keeps the notification volume sane.

A typical play session would Monitor `chat,whisper,combat,character` and use the regular CLI for everything else.

### 5. Tighter event-display semantics

Independent of the log work:

- Fix `await --until` to display non-matching events at the end (keep the cursor in sync with `_lastReportedEventIndex` semantics rather than its own snapshot).
- Increase the `await Task.Delay(250)` in `ExecuteCommand` to ~600 ms, OR replace it with a "wait until quiescent" helper that returns once no new events arrive for N consecutive 50 ms windows. The latter is more correct but more code.
- Document in `eraonline help` that piping through `head`/`grep` discards events from the in-memory buffer (use `tail` against the log file instead for filtered views).

## Implementation sketch

Smallest possible change set, in dependency order:

1. **Add monotonic event IDs to `GameState`.** Replace `_lastReportedEventIndex: int` with `_lastReportedEventId: long`. Add `Id` to `TimestampedEvent`. Bump an `_nextEventId` counter inside the `lock (RecentEvents)` in `AddEvent`. Rewrite `GetNewEvents` to filter by `Id > _lastReportedEventId`.
2. **Add the event log writer.** New `EventLog` class. Constructor takes the character data dir, opens an append `StreamWriter` with `AutoFlush = true`. Single `Write(category, text)` method. Wire it into `AddEvent` so every event goes to disk. Also add explicit `Write` calls in event handlers that have richer structured info than the free-form text (e.g. `OnStats` could write `stats|hp=...` instead of the unstructured chat text).
3. **Add `tail` command.** Read last N lines of `events.log`, optional `--since <id>` and `--filter <categories>`. Pure file read, no daemon round-trip required (so it works even if daemon is down, modulo log freshness).
4. **Add `stream` command.** Open the log, seek to end, poll for new lines with a small sleep, write them to stdout with line-buffered IO. Exits cleanly on SIGINT.
5. **Fix the await leak.** Re-display non-matching events at the end of `ExecuteAwait`.
6. **Tune the post-Invoke delay.** Either bump to 600 ms or swap in a quiescence helper.

Steps 1-2 are the core fix; the rest can land in follow-up commits.

## Open questions

- **Format**: pipe-delimited vs JSON-per-line. JSON is more flexible (structured fields for combat: attacker, target, damage, weapon) but harder to grep. Pipe-delimited reads better in a terminal. Recommendation: pipe-delimited with a stable category vocabulary; switch to JSON if/when downstream tooling needs it.
- **Log location**: per-character makes sense for multi-character setups (Sage's events vs Merchant_Haiku's events). Confirmed: `~/.local/share/eraonline/characters/<Name>/events.log`.
- **Categorization at the source**: do we tag events with categories in the SignalR handlers (clean, requires touching 24 handlers) or infer them in `AddEvent` from the message text (hacky, no handler changes)? Recommendation: tag at the source — most handlers already know what they are.
- **Log rotation**: not solved here. Acceptable for now since LLM sessions are bounded. Add `--max-log-size` later if we hit problems.
- **Log file concurrency**: only the daemon writes; many readers (`tail`, `stream`, external `tail -f`) can coexist. Standard append-only contract handles this on POSIX.

## Why this is worth doing now

The play session on 2026-04-18 lost most of the second half of an in-game conversation between Kyle and Sage, including a full direction change ("let's stop here for now", "let's log off and iterate") that I never received. The bug is a one-line fix in spirit but the design opportunity is bigger: an event log + Monitor integration changes the fundamental rhythm of LLM play from "poll and hope" to "do something else and be notified when something happens." That maps closer to how a human player experiences the game and reduces the per-tool-call cost of staying current with the world.
