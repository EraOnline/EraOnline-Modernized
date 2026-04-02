namespace EraOnline.Shared.Protocol;

/// <summary>
/// SignalR protocol message types. These replace the VB6 text-based protocol.
/// Phase 1 defines just the connection messages. More will be added in Phase 3+.
/// </summary>

// --- Client -> Server ---

public record LoginRequest(string Name, string Password, string ClientVersion);

public record CreateCharacterRequest(
    string Name,
    string Password,
    string Race,
    string Gender,
    string HomeTown,
    string SpecSkill1,
    string SpecSkill2,
    string SpecSkill3);

// --- Server -> Client ---

public record LoginResponse(bool Success, string? ErrorMessage = null);

public record ServerInfo(string Message);
