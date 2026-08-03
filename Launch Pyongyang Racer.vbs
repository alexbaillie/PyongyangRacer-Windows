Option Explicit

Dim shell, fso, gameDir, nodeExe, launcher, command
Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

gameDir = fso.GetParentFolderName(WScript.ScriptFullName)
nodeExe = "C:\Program Files\nodejs\node.exe"
launcher = gameDir & "\launch-game.js"
command = Chr(34) & nodeExe & Chr(34) & " " & Chr(34) & launcher & Chr(34)

shell.Run command, 0, False

