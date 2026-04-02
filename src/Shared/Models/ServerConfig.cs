using System.Text.Json.Serialization;

namespace EraOnline.Shared.Models;

/// <summary>Server configuration loaded from config.json (originally Server.ini).</summary>
public class ServerConfig
{
    [JsonPropertyName("port")] public int Port { get; set; }
    [JsonPropertyName("maxUsers")] public int MaxUsers { get; set; }
    [JsonPropertyName("clientVersion")] public string ClientVersion { get; set; } = "";
    [JsonPropertyName("idleLimit")] public int IdleLimit { get; set; }
    [JsonPropertyName("season")] public string Season { get; set; } = "";
    [JsonPropertyName("era")] public int Era { get; set; }
    [JsonPropertyName("year")] public int Year { get; set; }
    [JsonPropertyName("startingCities")] public List<StartingCity> StartingCities { get; set; } = [];
    [JsonPropertyName("gms")] public List<string> Gms { get; set; } = [];
}

public class StartingCity
{
    [JsonPropertyName("name")] public string Name { get; set; } = "";
    [JsonPropertyName("map")] public int Map { get; set; }
    [JsonPropertyName("x")] public int X { get; set; }
    [JsonPropertyName("y")] public int Y { get; set; }
}

/// <summary>NPC gossip entry loaded from gossip.json.</summary>
public class GossipEntry
{
    [JsonPropertyName("id")] public int Id { get; set; }
    [JsonPropertyName("text")] public string Text { get; set; } = "";
}

/// <summary>Quest definition loaded from quests.json.</summary>
public class QuestDef
{
    [JsonPropertyName("id")] public int Id { get; set; }
    [JsonPropertyName("type")] public int Type { get; set; }
    [JsonPropertyName("item")] public int Item { get; set; }
    [JsonPropertyName("sender")] public string Sender { get; set; } = "";
    [JsonPropertyName("receiver")] public string Receiver { get; set; } = "";
    [JsonPropertyName("rewardItem")] public int RewardItem { get; set; }
    [JsonPropertyName("rewardExp")] public int RewardExp { get; set; }
    [JsonPropertyName("rewardGold")] public int RewardGold { get; set; }
}
