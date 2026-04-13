using System.Net.Sockets;
using System.Text;

namespace EraOnline.Client.CLI.IPC;

/// <summary>
/// Short-lived TCP client that sends a command to the running daemon and returns the response.
/// </summary>
public static class IpcClient
{
    public static async Task<string> SendCommand(int port, string command, int timeoutMs = 10000)
    {
        using var client = new TcpClient();
        try
        {
            await client.ConnectAsync("127.0.0.1", port);
        }
        catch (SocketException)
        {
            return "Error: No session running. Start one with: eraonline start --name <name> --password <pw>";
        }

        client.ReceiveTimeout = timeoutMs;
        client.SendTimeout = 5000;

        var stream = client.GetStream();

        // Send command (length-prefixed)
        var cmdBytes = Encoding.UTF8.GetBytes(command);
        var lenBytes = BitConverter.GetBytes(cmdBytes.Length);
        await stream.WriteAsync(lenBytes);
        await stream.WriteAsync(cmdBytes);
        await stream.FlushAsync();

        // Read response (length-prefixed)
        var respLenBuf = new byte[4];
        await stream.ReadExactlyAsync(respLenBuf);
        var respLen = BitConverter.ToInt32(respLenBuf);
        if (respLen <= 0 || respLen > 1_000_000) return "Error: Invalid response from daemon.";

        var respBuf = new byte[respLen];
        await stream.ReadExactlyAsync(respBuf);
        return Encoding.UTF8.GetString(respBuf);
    }
}
