using System.Net;
using System.Net.Sockets;
using System.Text;
using EraOnline.Client.CLI.Session;

namespace EraOnline.Client.CLI.IPC;

/// <summary>
/// TCP listener that accepts commands from the CLI command client.
/// Runs inside the daemon process alongside the SignalR connection.
/// </summary>
public class IpcServer : IAsyncDisposable
{
    private readonly int _port;
    private readonly GameSession _session;
    private TcpListener? _listener;
    private CancellationTokenSource? _cts;
    private Task? _listenTask;

    /// <summary>Fires when a stop command is received via IPC.</summary>
    public event Action? StopRequested;

    public IpcServer(int port, GameSession session)
    {
        _port = port;
        _session = session;
    }

    public void Start()
    {
        _cts = new CancellationTokenSource();
        _listener = new TcpListener(IPAddress.Loopback, _port);
        _listener.Start();
        _listenTask = AcceptLoop(_cts.Token);
    }

    private async Task AcceptLoop(CancellationToken ct)
    {
        while (!ct.IsCancellationRequested)
        {
            try
            {
                var client = await _listener!.AcceptTcpClientAsync(ct);
                // Handle each client in a fire-and-forget task (commands are short-lived)
                _ = HandleClient(client);
            }
            catch (OperationCanceledException) { break; }
            catch (ObjectDisposedException) { break; }
            catch { /* ignore transient errors */ }
        }
    }

    private async Task HandleClient(TcpClient client)
    {
        try
        {
            using (client)
            {
                client.ReceiveTimeout = 5000;
                client.SendTimeout = 5000;

                var stream = client.GetStream();

                // Read command (length-prefixed: 4 bytes big-endian length + UTF-8 string)
                var lenBuf = new byte[4];
                await stream.ReadExactlyAsync(lenBuf);
                var len = BitConverter.ToInt32(lenBuf);
                if (len <= 0 || len > 65536) return;

                var cmdBuf = new byte[len];
                await stream.ReadExactlyAsync(cmdBuf);
                var command = Encoding.UTF8.GetString(cmdBuf);

                // Execute command
                string response;
                if (command == "__stop__")
                {
                    response = "Session stopping.";
                    await WriteResponse(stream, response);
                    StopRequested?.Invoke();
                    _cts?.Cancel();
                    return;
                }
                else if (command == "__ping__")
                {
                    response = "pong";
                }
                else
                {
                    response = await _session.ExecuteCommand(command);
                }

                await WriteResponse(stream, response);
            }
        }
        catch { /* client disconnected or timed out */ }
    }

    private static async Task WriteResponse(NetworkStream stream, string response)
    {
        var responseBytes = Encoding.UTF8.GetBytes(response);
        var lenBytes = BitConverter.GetBytes(responseBytes.Length);
        await stream.WriteAsync(lenBytes);
        await stream.WriteAsync(responseBytes);
        await stream.FlushAsync();
    }

    public async ValueTask DisposeAsync()
    {
        _cts?.Cancel();
        _listener?.Stop();
        if (_listenTask != null)
        {
            try { await _listenTask; } catch { }
        }
        _cts?.Dispose();
    }
}
