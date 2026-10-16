param(
    [string]$FfdecJar = $env:FFDEC_JAR,
    [string]$Java = "java"
)

# Rebuilds pyracer.swf (Windows) and ruffle/pyracer.swf (macOS) from
# patches/original/pyracer.swf using JPEXS Free Flash Decompiler.
# Usage: .\patches\build.ps1 -FfdecJar C:\path\to\ffdec.jar

$ErrorActionPreference = 'Stop'

if (-not $FfdecJar -or -not (Test-Path -LiteralPath $FfdecJar)) {
    throw "Pass -FfdecJar <path to ffdec.jar> (JPEXS Free Flash Decompiler 26.x) or set the FFDEC_JAR environment variable."
}

$patchesDir = $PSScriptRoot
$repoRoot = Split-Path -Parent $patchesDir
$original = Join-Path $patchesDir 'original\pyracer.swf'
if (-not (Test-Path -LiteralPath $original)) { throw "Missing $original" }

function Build-Swf {
    param([string[]]$PatchSets, [string]$OutFile)

    $stage = Join-Path ([System.IO.Path]::GetTempPath()) ('pyracer-build-' + [guid]::NewGuid().ToString('N'))
    $scripts = Join-Path $stage 'scripts'
    New-Item -ItemType Directory -Force -Path $scripts | Out-Null
    try {
        foreach ($set in $PatchSets) {
            $src = Join-Path $patchesDir $set
            Get-ChildItem -LiteralPath $src -Recurse -File | ForEach-Object {
                $rel = $_.FullName.Substring($src.Length).TrimStart('\', '/')
                $dest = Join-Path $scripts $rel
                New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
                Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
            }
        }
        & $Java -jar $FfdecJar -importScript $original $OutFile $stage
        if ($LASTEXITCODE -ne 0) { throw "FFDec failed with exit code $LASTEXITCODE while building $OutFile" }
        Write-Host ("Built {0} ({1:N0} bytes) with patches: {2}" -f $OutFile, (Get-Item -LiteralPath $OutFile).Length, ($PatchSets -join ' + '))
    }
    finally {
        if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
    }
}

Build-Swf -PatchSets @('autodrive', 'settings') -OutFile (Join-Path $repoRoot 'pyracer.swf')
Build-Swf -PatchSets @('ruffle', 'autodrive', 'settings') -OutFile (Join-Path $repoRoot 'ruffle\pyracer.swf')

# Loading-screen tip: ten -> three (needs Python 3)
if (Get-Command python -ErrorAction SilentlyContinue) {
    foreach ($swf in @((Join-Path $repoRoot 'pyracer.swf'), (Join-Path $repoRoot 'ruffle\pyracer.swf'))) {
        & python (Join-Path $patchesDir 'textures\patch_tip.py') $swf $swf
    }
} else {
    Write-Warning 'Python not found: the loading-screen tip still says ten vehicles.'
}
