$ErrorActionPreference = 'Stop'

$projectDirectory = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $PSScriptRoot 'Program.cs'
$outputPath = Join-Path $projectDirectory 'Launch Pyongyang Racer.exe'
$compilerCandidates = @(
    "$env:WINDIR\Microsoft.NET\Framework64\v4.0.30319\csc.exe",
    "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe"
)
$compilerPath = $compilerCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1

if (-not $compilerPath) {
    throw 'The Windows .NET Framework C# compiler was not found.'
}

& $compilerPath `
    /nologo `
    /optimize+ `
    /target:winexe `
    /platform:anycpu `
    /reference:System.dll `
    /reference:System.Windows.Forms.dll `
    "/out:$outputPath" `
    $sourcePath

if ($LASTEXITCODE -ne 0) {
    throw "The launcher build failed with exit code $LASTEXITCODE."
}

Write-Host "Built $outputPath"
