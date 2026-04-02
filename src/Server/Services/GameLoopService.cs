using EraOnline.Shared.Constants;

namespace EraOnline.Server.Services;

/// <summary>
/// Main game loop running at 50ms tick rate (20 ticks/second).
/// VB6: GameTimer in frmMain.frm with Interval=50.
/// Each tick will process NPC AI, idle detection, world state updates.
/// For Phase 1 this just ticks and logs periodically to prove it's alive.
/// </summary>
public class GameLoopService : BackgroundService
{
    private readonly ILogger<GameLoopService> _logger;
    private long _tickCount;

    public long TickCount => _tickCount;

    public GameLoopService(ILogger<GameLoopService> logger)
    {
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Game loop started ({Interval}ms tick rate)", GameConstants.GameTickInterval);

        using var timer = new PeriodicTimer(TimeSpan.FromMilliseconds(GameConstants.GameTickInterval));

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            _tickCount++;

            // Log every 1000 ticks (~50 seconds)
            if (_tickCount % 1000 == 0)
            {
                _logger.LogDebug("Game loop tick {Tick}", _tickCount);
            }
        }

        _logger.LogInformation("Game loop stopped at tick {Tick}", _tickCount);
    }
}
