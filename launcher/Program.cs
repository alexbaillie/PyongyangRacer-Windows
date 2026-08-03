using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Windows.Forms;

[assembly: AssemblyTitle("Pyongyang Racer Launcher")]
[assembly: AssemblyDescription("Standalone local launcher for Pyongyang Racer")]
[assembly: AssemblyCompany("PyongyangRacer-Windows")]
[assembly: AssemblyProduct("Pyongyang Racer Launcher")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]

namespace PyongyangRacerLauncher
{
    internal static class Program
    {
        private static readonly object LogLock = new object();

        private static readonly Dictionary<string, string> AllowedFiles =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "1.dat", "1.dat" },
                { "common.dat", "common.dat" },
                { "common.txt", "common.txt" },
                { "info.txt", "info.txt" },
                { "PreGame.mp3", "PreGame.mp3" },
                { "pyracer.swf", "pyracer.swf" },
                { "sound.dat", "sound.dat" },
                { "symbol.dat", "symbol.dat" }
            };

        private static readonly Dictionary<string, string> ContentTypes =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { ".dat", "application/octet-stream" },
                { ".mp3", "audio/mpeg" },
                { ".swf", "application/x-shockwave-flash" },
                { ".txt", "text/plain; charset=utf-8" }
            };

        private static string gameDirectory;
        private static string logPath;
        private static TcpListener listener;
        private static volatile bool stopping;

        [STAThread]
        private static int Main()
        {
            gameDirectory = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
            logPath = Path.Combine(gameDirectory, "launch.log");
            InitializeLog();

            try
            {
                string playerPath = Path.Combine(gameDirectory, "PyongyangRacer.exe");
                ValidatePackage(playerPath);

                listener = new TcpListener(IPAddress.Loopback, 0);
                listener.Start();

                Thread serverThread = new Thread(ServerLoop);
                serverThread.IsBackground = true;
                serverThread.Name = "Pyongyang Racer local server";
                serverThread.Start();

                int port = ((IPEndPoint)listener.LocalEndpoint).Port;
                string gameUrl = "http://127.0.0.1:" + port + "/pyracer.swf";
                Log("Serving " + gameUrl);

                ProcessStartInfo startInfo = new ProcessStartInfo();
                startInfo.FileName = playerPath;
                startInfo.Arguments = gameUrl;
                startInfo.WorkingDirectory = gameDirectory;
                startInfo.UseShellExecute = false;

                using (Process player = Process.Start(startInfo))
                {
                    if (player == null)
                    {
                        throw new InvalidOperationException("The Flash projector did not start.");
                    }

                    player.WaitForExit();
                    Log("Player exited with code=" + player.ExitCode);
                    return player.ExitCode;
                }
            }
            catch (Exception error)
            {
                Log("LAUNCHER ERROR " + error);
                MessageBox.Show(
                    error.Message,
                    "Pyongyang Racer could not start",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return 1;
            }
            finally
            {
                stopping = true;
                if (listener != null)
                {
                    try
                    {
                        listener.Stop();
                    }
                    catch
                    {
                    }
                }
            }
        }

        private static void ValidatePackage(string playerPath)
        {
            List<string> missingFiles = new List<string>();

            if (!File.Exists(playerPath))
            {
                missingFiles.Add(Path.GetFileName(playerPath));
            }

            foreach (string fileName in AllowedFiles.Values)
            {
                if (!File.Exists(Path.Combine(gameDirectory, fileName)))
                {
                    missingFiles.Add(fileName);
                }
            }

            if (missingFiles.Count > 0)
            {
                throw new FileNotFoundException(
                    "Keep the launcher in the extracted game folder. Missing: " +
                    string.Join(", ", missingFiles.ToArray()));
            }
        }

        private static void ServerLoop()
        {
            while (!stopping)
            {
                try
                {
                    TcpClient client = listener.AcceptTcpClient();
                    Thread clientThread = new Thread(delegate() { HandleClient(client); });
                    clientThread.IsBackground = true;
                    clientThread.Start();
                }
                catch (SocketException error)
                {
                    if (!stopping)
                    {
                        Log("SERVER ERROR " + error);
                    }
                }
                catch (ObjectDisposedException)
                {
                    if (!stopping)
                    {
                        Log("SERVER ERROR Listener closed unexpectedly.");
                    }
                }
            }
        }

        private static void HandleClient(TcpClient client)
        {
            using (client)
            {
                try
                {
                    client.ReceiveTimeout = 10000;
                    client.SendTimeout = 10000;

                    using (NetworkStream stream = client.GetStream())
                    using (StreamReader reader = new StreamReader(
                        stream,
                        Encoding.ASCII,
                        false,
                        8192,
                        true))
                    {
                        string requestLine = reader.ReadLine();
                        if (string.IsNullOrEmpty(requestLine))
                        {
                            return;
                        }

                        string headerLine;
                        do
                        {
                            headerLine = reader.ReadLine();
                        }
                        while (!string.IsNullOrEmpty(headerLine));

                        string[] requestParts = requestLine.Split(' ');
                        if (requestParts.Length < 2)
                        {
                            SendError(stream, 400, "Bad Request", "Bad request");
                            return;
                        }

                        string method = requestParts[0].ToUpperInvariant();
                        if (method != "GET" && method != "HEAD")
                        {
                            SendError(stream, 405, "Method Not Allowed", "Method not allowed");
                            return;
                        }

                        string requestTarget = requestParts[1];
                        int queryIndex = requestTarget.IndexOf('?');
                        if (queryIndex >= 0)
                        {
                            requestTarget = requestTarget.Substring(0, queryIndex);
                        }

                        string requestedName = Uri.UnescapeDataString(requestTarget).TrimStart('/');
                        string actualName;
                        if (!AllowedFiles.TryGetValue(requestedName, out actualName))
                        {
                            Log("404 " + method + " /" + requestedName);
                            SendError(stream, 404, "Not Found", "Not found");
                            return;
                        }

                        string filePath = Path.Combine(gameDirectory, actualName);
                        FileInfo file = new FileInfo(filePath);
                        string extension = file.Extension;
                        string contentType;
                        if (!ContentTypes.TryGetValue(extension, out contentType))
                        {
                            contentType = "application/octet-stream";
                        }

                        Log("200 " + method + " /" + actualName);
                        WriteHeaders(stream, 200, "OK", contentType, file.Length);

                        if (method == "GET")
                        {
                            using (FileStream input = file.OpenRead())
                            {
                                input.CopyTo(stream);
                            }
                        }
                    }
                }
                catch (Exception error)
                {
                    Log("REQUEST ERROR " + error);
                }
            }
        }

        private static void SendError(
            NetworkStream stream,
            int statusCode,
            string reason,
            string message)
        {
            byte[] body = Encoding.UTF8.GetBytes(message);
            WriteHeaders(stream, statusCode, reason, "text/plain; charset=utf-8", body.Length);
            stream.Write(body, 0, body.Length);
        }

        private static void WriteHeaders(
            NetworkStream stream,
            int statusCode,
            string reason,
            string contentType,
            long contentLength)
        {
            string headers =
                "HTTP/1.1 " + statusCode + " " + reason + "\r\n" +
                "Content-Type: " + contentType + "\r\n" +
                "Content-Length: " + contentLength + "\r\n" +
                "Cache-Control: no-store\r\n" +
                "Connection: close\r\n\r\n";

            byte[] headerBytes = Encoding.ASCII.GetBytes(headers);
            stream.Write(headerBytes, 0, headerBytes.Length);
        }

        private static void InitializeLog()
        {
            try
            {
                File.WriteAllText(logPath, string.Empty, Encoding.UTF8);
            }
            catch
            {
            }
        }

        private static void Log(string message)
        {
            try
            {
                lock (LogLock)
                {
                    File.AppendAllText(
                        logPath,
                        DateTime.UtcNow.ToString("o") + " " + message + "\r\n",
                        Encoding.UTF8);
                }
            }
            catch
            {
            }
        }
    }
}
