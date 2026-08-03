"use strict";

const fs = require("fs");
const http = require("http");
const path = require("path");
const { spawn } = require("child_process");

const gameDir = __dirname;
const logPath = path.join(gameDir, "launch.log");
const playerPath = path.join(gameDir, "PyongyangRacer.exe");

const contentTypes = {
  ".dat": "application/octet-stream",
  ".mp3": "audio/mpeg",
  ".swf": "application/x-shockwave-flash",
  ".txt": "text/plain; charset=utf-8",
};

const allowedFiles = new Map(
  [
    "1.dat",
    "common.dat",
    "common.txt",
    "info.txt",
    "PreGame.mp3",
    "pyracer.swf",
    "sound.dat",
    "symbol.dat",
  ].map((name) => [name.toLowerCase(), name]),
);

function log(message) {
  fs.appendFileSync(logPath, `${new Date().toISOString()} ${message}\r\n`);
}

fs.writeFileSync(logPath, "");

const server = http.createServer((request, response) => {
  const requestedName = decodeURIComponent(new URL(request.url, "http://127.0.0.1").pathname)
    .replace(/^\/+/, "")
    .toLowerCase();
  const actualName = allowedFiles.get(requestedName);

  if (!actualName) {
    log(`404 ${request.method} /${requestedName}`);
    response.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
    response.end("Not found");
    return;
  }

  const filePath = path.join(gameDir, actualName);
  log(`200 ${request.method} /${actualName}`);
  response.writeHead(200, {
    "Cache-Control": "no-store",
    "Content-Type": contentTypes[path.extname(actualName).toLowerCase()] || "application/octet-stream",
  });
  fs.createReadStream(filePath).pipe(response);
});

server.on("error", (error) => {
  log(`SERVER ERROR ${error.stack || error.message}`);
  process.exitCode = 1;
});

server.listen(0, "127.0.0.1", () => {
  const address = server.address();
  const gameUrl = `http://127.0.0.1:${address.port}/pyracer.swf`;
  log(`Serving ${gameUrl}`);

  const player = spawn(playerPath, [gameUrl], {
    cwd: gameDir,
    detached: false,
    stdio: "ignore",
    windowsHide: false,
  });

  player.once("error", (error) => {
    log(`PLAYER ERROR ${error.stack || error.message}`);
    server.close(() => process.exit(1));
  });

  player.once("exit", (code, signal) => {
    log(`Player exited with code=${code} signal=${signal}`);
    server.close(() => process.exit(code || 0));
  });
});

