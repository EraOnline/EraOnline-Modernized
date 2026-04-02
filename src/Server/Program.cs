using EraOnline.Server.Hubs;
using EraOnline.Server.Services;

var builder = WebApplication.CreateBuilder(args);

// Game services
builder.Services.AddSingleton<GameDataService>();
builder.Services.AddHostedService<GameLoopService>();

// SignalR
builder.Services.AddSignalR();

var app = builder.Build();

// Load all game data before accepting connections
var gameData = app.Services.GetRequiredService<GameDataService>();
await gameData.LoadAllAsync();

// Endpoints
app.MapHub<GameHub>("/gamehub");
app.MapGet("/", () => Results.Content(
    "<h1>Era Online Server</h1><p>It's the dawn of a new era.</p>",
    "text/html"));

app.Run();
