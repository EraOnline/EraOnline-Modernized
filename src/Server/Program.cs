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

// Resolve paths
var clientWebWwwroot = Path.GetFullPath(Path.Combine(app.Environment.ContentRootPath, "..", "Client.Web", "wwwroot"));
var dataPath = app.Configuration.GetValue<string>("GameDataPath")
    ?? Path.Combine(app.Environment.ContentRootPath, "..", "..", "tools", "eo-data-converter", "data");
var fullDataPath = Path.GetFullPath(dataPath);

app.Logger.LogInformation("Client.Web wwwroot: {Path} (exists: {Exists})", clientWebWwwroot, Directory.Exists(clientWebWwwroot));
app.Logger.LogInformation("Game data path: {Path} (exists: {Exists})", fullDataPath, Directory.Exists(fullDataPath));
app.Logger.LogInformation("Grh directory: {Path} (exists: {Exists})", Path.Combine(fullDataPath, "grh"), Directory.Exists(Path.Combine(fullDataPath, "grh")));

// Serve game data files at /data FIRST (before the catch-all client files)
if (Directory.Exists(fullDataPath))
{
    app.UseStaticFiles(new StaticFileOptions
    {
        FileProvider = new PhysicalFileProvider(fullDataPath),
        RequestPath = "/data",
        ServeUnknownFileTypes = false
    });
}

// Serve Client.Web's wwwroot (index.html, js/renderer.js, etc.)
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

// Endpoints
app.MapHub<GameHub>("/gamehub");

app.Run();
