using Microsoft.Extensions.FileProviders;
using EraOnline.Server.Hubs;
using EraOnline.Server.Services;

// Set WebRootPath to Client.Web's wwwroot so all static files are served from there
var clientWebWwwroot = Path.GetFullPath(Path.Combine(Directory.GetCurrentDirectory(), "..", "Client.Web", "wwwroot"));

var builder = WebApplication.CreateBuilder(new WebApplicationOptions
{
    Args = args,
    WebRootPath = clientWebWwwroot
});

// Game services
builder.Services.AddSingleton<GameDataService>();
builder.Services.AddHostedService<GameLoopService>();

// SignalR
builder.Services.AddSignalR();

var app = builder.Build();

// Load all game data before accepting connections
var gameData = app.Services.GetRequiredService<GameDataService>();
await gameData.LoadAllAsync();

app.Logger.LogInformation("WebRootPath: {Path} (exists: {Exists})", app.Environment.WebRootPath, Directory.Exists(app.Environment.WebRootPath));

// Serve all static files from Client.Web/wwwroot
app.UseDefaultFiles();
app.UseStaticFiles();

// Endpoints
app.MapHub<GameHub>("/gamehub");

app.Run();
