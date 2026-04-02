using Microsoft.AspNetCore.SignalR;
using EraOnline.Server.Services;

namespace EraOnline.Server.Hubs;

/// <summary>
/// SignalR hub for game communication.
/// VB6: Replaces the text-based TCP protocol (CSWSK32.OCX SocketWrench).
/// Phase 1: connection lifecycle only. Game logic added in Phase 3+.
/// </summary>
public class GameHub : Hub
{
    private readonly GameDataService _gameData;
    private readonly ILogger<GameHub> _logger;

    public GameHub(GameDataService gameData, ILogger<GameHub> logger)
    {
        _gameData = gameData;
        _logger = logger;
    }

    public override Task OnConnectedAsync()
    {
        _logger.LogInformation("Client connected: {ConnectionId}", Context.ConnectionId);
        return base.OnConnectedAsync();
    }

    public override Task OnDisconnectedAsync(Exception? exception)
    {
        _logger.LogInformation("Client disconnected: {ConnectionId}", Context.ConnectionId);
        return base.OnDisconnectedAsync(exception);
    }

    /// <summary>Simple ping to verify the connection works.</summary>
    public string Ping() => "Pong";

    /// <summary>Returns basic server info for connection testing.</summary>
    public object GetServerInfo() => new
    {
        Objects = _gameData.Objects.Count,
        Npcs = _gameData.Npcs.Count,
        Spells = _gameData.Spells.Count,
        Maps = _gameData.Maps.Count,
        Season = _gameData.Config.Season,
        Era = _gameData.Config.Era
    };
}
