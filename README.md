# Pyongyang Racer for Windows

A standalone Windows package of **Pyongyang Racer**, the 2012 browser racing game. Download, extract, double-click, play. No Flashpoint, no browser plugin, no separate runtime to install.

> **Beta testers:** please read [Quick start](#quick-start) and [Reporting a problem](#reporting-a-problem). Everything else is optional.

---

## Quick start

1. **Download the latest `PyongyangRacer-Windows-*.zip`** from the [Releases page](https://github.com/alexbaillie/PyongyangRacer-Windows/releases/latest).
2. **Extract the whole ZIP** to a normal folder, for example your Desktop or Documents. Do not run the game from inside the ZIP window.
3. Open the extracted folder and **double-click `Launch Pyongyang Racer.exe`**.
4. The game opens in its own window. Close that window when you are done.

That is it. The first launch can take a few seconds while the game loads its assets.

## Requirements

| | |
|---|---|
| Operating system | Windows 10 or Windows 11 |
| Extra software | None. Everything needed is in the folder. |
| Internet | Not needed. The game runs entirely offline. |

## Controls

| Key | Action |
|---|---|
| Up arrow | Accelerate |
| Down arrow | Brake |
| Left / Right arrows | Steer |
| Space | Horn |

## Troubleshooting

**"Windows protected your PC" (blue SmartScreen box)**
The launcher is not code-signed, so Windows may warn on first run. Click **More info**, then **Run anyway**. This only happens once.

**"Pyongyang Racer could not start" with a list of missing files**
The launcher cannot find the game files next to it. This usually means the ZIP was not fully extracted, or the launcher was moved out of its folder. Re-extract the ZIP and run the launcher from inside the extracted folder.

**Nothing happens, or the window closes immediately**
Open `launch.log` in the game folder. It records exactly what the launcher did on the last run. Send it in with your bug report (see below).

**Game window opens but stays black or silent**
Wait ten seconds; the sound and graphics files load after the window appears. If it is still black, check `launch.log` for lines that do not start with `200`.

**Antivirus quarantined the launcher**
Some antivirus tools flag small unsigned programs. Restore the file and add the game folder as an exception, or build the launcher yourself from source (see [For developers](#for-developers)).

## Reporting a problem

Open an issue on this repository, or message me directly. Please include:

- **What you did** and **what happened** instead of what you expected.
- **Your Windows version** (press `Win + R`, type `winver`, press Enter).
- **The `launch.log` file** from the game folder. It is rewritten on every launch, so grab it right after the problem happens.
- A **screenshot** if the problem is visual.

Feedback on gameplay, difficulty, and anything that felt confusing is just as welcome as crash reports.

## How it works

`Launch Pyongyang Racer.exe` is a small helper. When you run it, it:

1. Checks that all the game files are present in the same folder.
2. Starts a tiny web server that only listens on your own machine (`127.0.0.1`) and only serves the eight game files. Nothing is reachable from the network.
3. Opens the game in `PyongyangRacer.exe`, which is Adobe's signed standalone Flash projector.
4. Shuts the server down when you close the game.

Every launch is logged to `launch.log`.

## What is in the folder

| File | Purpose |
|---|---|
| `Launch Pyongyang Racer.exe` | Start here. The launcher. |
| `PyongyangRacer.exe` | Adobe Flash standalone projector that runs the game. |
| `pyracer.swf` | The game itself. |
| `1.dat`, `common.dat`, `symbol.dat`, `sound.dat` | Game graphics and audio data. |
| `common.txt`, `info.txt` | Game text and the landmark descriptions shown while driving. |
| `PreGame.mp3` | Menu music. |
| `launch.log` | Created on each run. Useful for bug reports. |
| `launcher/` | Source code for the launcher. Not needed to play. |

## For developers

The launcher is a single C# file with no dependencies beyond the .NET Framework that ships with Windows. To rebuild it, open PowerShell in the repository folder and run:

```powershell
.\launcher\build.ps1
```

This compiles `launcher/Program.cs` with the built-in .NET Framework compiler and overwrites `Launch Pyongyang Racer.exe`.

## Notes

This private repository exists for archival and personal-use purposes. The game and bundled assets remain the property of their respective owners. Please do not redistribute the package outside the beta group.
