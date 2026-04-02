using Microsoft.Extensions.FileProviders;
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

// Serve Client.Web's wwwroot (index.html, js/renderer.js, etc.)
var clientWebWwwroot = Path.GetFullPath(Path.Combine(app.Environment.ContentRootPath, "..", "Client.Web", "wwwroot"));
if (Directory.Exists(clientWebWwwroot))
{
    app.UseDefaultFiles(new DefaultFilesOptions
    {
        FileProvider = new PhysicalFileProvider(clientWebWwwroot)
    });
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(clientWebWwwroot)
    });
}

// Serve game data files (JSON + sprite PNGs) from eo-data-converter/data
var dataPath = app.Configuration.GetValue<string>("GameDataPath")
    ?? Path.Combine(app.Environment.ContentRootPath, "..", "..", "tools", "eo-data-converter", "data");
var fullDataPath = Path.GetFullPath(dataPath);
if (Directory.Exists(fullDataPath))
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(fullDataPath),
        RequestPath = "/data"
    });
}

// Endpoints
app.MapHub<GameHub>("/gamehub");

app.Run();
