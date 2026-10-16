# Pyongyang Racer for Windows

A standalone package of **Pyongyang Racer**, the 2012 browser racing game, for Windows and macOS. Download, extract, double-click, play. No Flashpoint, no browser plugin, no separate runtime to install.

> **Beta testers:** please read [Quick start](#quick-start) (Windows) or [macOS](#macos) and [Reporting a problem](#reporting-a-problem). Everything else is optional.

---

## Quick start (Windows)

1. **Download the latest `PyongyangRacer-Windows-*.zip`** from the [Releases page](https://github.com/alexbaillie/PyongyangRacer-Windows/releases/latest). Mac users: see [macOS](#macos) below.
2. **Extract the whole ZIP** to a normal folder, for example your Desktop or Documents. Do not run the game from inside the ZIP window.
3. Open the extracted folder and **double-click `Launch Pyongyang Racer.exe`**.
4. The game opens in its own window. Close that window when you are done.

That is it. The first launch can take a few seconds while the game loads its assets.

## macOS

1. **Download the latest `PyongyangRacer-macOS-*.tar.gz`** from the [Releases page](https://github.com/alexbaillie/PyongyangRacer-Windows/releases/latest).
2. **Double-click the file** to extract it. You get a `PyongyangRacer-macOS` folder.
3. Open that folder and **double-click `Ruffle.app`**. If macOS asks whether to open an app downloaded from the internet, click **Open**. This happens once.
4. In Ruffle, choose **File > Open...** and pick `pyracer.swf` from the same folder. Dragging the file onto the Ruffle window also works.
5. Click "go now!" on the welcome screen after the intro.

Works on Intel and Apple Silicon Macs, macOS 11 or later. Keep all the files together in the folder; the game loads its data from next to `pyracer.swf`.

The Mac build runs the game in [Ruffle](https://ruffle.rs), an open-source Flash player, instead of Adobe's projector. Ruffle cannot yet draw one thing the game relies on, so the Mac copy of `pyracer.swf` carries a small rendering patch. Details are in [patches/README.md](patches/README.md). Gameplay, tracks and controls are identical.

## Requirements

| | |
|---|---|
| Operating system | Windows 10 or 11, or macOS 11 or later |
| Extra software | None. Everything needed is in the folder. |
| Internet | Not needed. The game runs entirely offline. |

## Controls

| Key | Action |
|---|---|
| Up arrow | Accelerate |
| Down arrow | Brake |
| Left / Right arrows | Steer |
| Space | Horn |

**Autodrive cheat.** During a race, press **F**. The car then drives itself round the course, 50% faster than normal, in the lane just right of the yellow centre line, never leaves the road, only changes lane to get past a slower car, and never runs out of fuel. A message on screen confirms it. Press **F** again to take back control.

## Troubleshooting

**"Windows protected your PC" (blue SmartScreen box)**
The launcher is not code-signed, so Windows may warn on first run. Click **More info**, then **Run anyway**. This only happens once.

**"Pyongyang Racer could not start" with a list of missing files**
The launcher cannot find the game files next to it. This usually means the ZIP was not fully extracted, or the launcher was moved out of its folder. Re-extract the ZIP and run the launcher from inside the extracted folder.

**Nothing happens, or the window closes immediately**
Open `launch.log` in the game folder. It records exactly what the launcher did on the last run. Send it in with your bug report (see below).

**Game window opens but stays black or silent**
Wait ten seconds; the sound and graphics files load after the window appears. If it is still black, check `launch.log` for lines that do not start with `200`.

**macOS: "Ruffle.app can't be opened" or "is damaged"**
Ruffle is signed and notarized, so this should not happen. If it does, re-download the `.tar.gz` and extract it by double-clicking in Finder rather than with a third-party tool. On macOS 15 or later, look in System Settings > Privacy & Security for an **Open Anyway** button.

**macOS: game opens but scenery looks wrong**
Make sure you opened the `pyracer.swf` from the Mac download, not the one from the Windows zip. Only the Mac copy has the Ruffle rendering patch.

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
| `pyracer.swf` | The game itself, with the autodrive cheat added (see `patches/`). |
| `1.dat`, `common.dat`, `symbol.dat`, `sound.dat` | Game graphics and audio data. |
| `common.txt`, `info.txt` | Game text and the landmark descriptions shown while driving. |
| `PreGame.mp3` | Menu music. |
| `launch.log` | Created on each run. Useful for bug reports. |
| `launcher/` | Source code for the Windows launcher. Not needed to play. |
| `ruffle/` | The Mac copy of `pyracer.swf`, which also carries the Ruffle rendering patch. |
| `patches/` | The untouched original game, the patch sources, and a build script. Not needed to play. |

## For developers

The launcher is a single C# file with no dependencies beyond the .NET Framework that ships with Windows. To rebuild it, open PowerShell in the repository folder and run:

```powershell
.\launcher\build.ps1
```

This compiles `launcher/Program.cs` with the built-in .NET Framework compiler and overwrites `Launch Pyongyang Racer.exe`.

The two `pyracer.swf` files are the original game with a handful of ActionScript classes replaced. [patches/README.md](patches/README.md) explains each change and how to rebuild them with `patches/build.ps1`.

## Notes

This repository exists for archival and personal-use purposes. The game and bundled assets remain the property of their respective owners. Please do not redistribute the package outside the beta group.
