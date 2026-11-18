param(
    [ValidateSet('serial','race','critical','atomic','reduction','lock')]
    [string]$Variant = 'serial',
    [string]$Compiler = 'C:\msys64\ucrt64\bin\g++.exe'
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$out = Join-Path $root "build\$Variant"
New-Item -ItemType Directory -Force -Path $out | Out-Null
Get-ChildItem -LiteralPath $root -File | Where-Object { $_.Extension -in '.h','.cc' } | Copy-Item -Destination $out
Copy-Item -LiteralPath (Join-Path $root "camera-$Variant.h") -Destination (Join-Path $out 'camera.h') -Force
$env:Path = (Split-Path -Parent $Compiler) + ';' + $env:Path
$argsList = @('-std=c++17','-O3')
if ($Variant -ne 'serial') { $argsList += '-fopenmp' }
$argsList += @((Join-Path $out 'main.cc'),'-o',(Join-Path $out "raytracer-$Variant.exe"))
& $Compiler @argsList
if ($LASTEXITCODE -ne 0) { throw "Compilation failed: $LASTEXITCODE" }
if (!(Test-Path -LiteralPath (Join-Path $out "raytracer-$Variant.exe"))) { throw 'Executable missing' }
Write-Host "Built build\$Variant\raytracer-$Variant.exe"

