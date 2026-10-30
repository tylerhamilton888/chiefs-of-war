param([Parameter(Mandatory=$true)][string]$Archive)
$ErrorActionPreference = 'Stop'
$root = Join-Path $env:RUNNER_TEMP 'Chiefs of War extracted playtest'
Expand-Archive -LiteralPath $Archive -DestinationPath $root -Force
$exe = Join-Path $root 'ChiefsOfWar.exe'
if (!(Test-Path -LiteralPath $exe)) { throw 'The extracted game executable is missing.' }
$executables = @(Get-ChildItem -LiteralPath $root -Recurse -Filter '*.exe')
if ($executables.Count -ne 1) { throw 'The player package must contain exactly one game executable.' }
$env:APPDATA = Join-Path $env:RUNNER_TEMP 'chiefs-isolated-appdata'
New-Item -ItemType Directory -Force -Path $env:APPDATA | Out-Null
function Invoke-GameSmoke([string]$Name, [string[]]$GameArgs) {
    $log = Join-Path $env:RUNNER_TEMP ($Name + '-startup.log')
    $arguments = @('--headless', '--audio-driver', 'Dummy', '--quit-after', '180', '--log-file', ('"' + $log + '"'), '--') + $GameArgs
    # Deliberately launch outside the extracted directory and from a path with spaces.
    $process = Start-Process -FilePath $exe -ArgumentList $arguments -WorkingDirectory $env:RUNNER_TEMP -PassThru
    if (!$process.WaitForExit(120000)) { $process.Kill(); throw "$Name startup timed out." }
    $process.Refresh()
    if ($process.ExitCode -ne 0) { throw "$Name exited with code $($process.ExitCode)." }
    if (!(Test-Path -LiteralPath $log)) { throw "$Name did not produce its startup log." }
    $contents = Get-Content -LiteralPath $log -Raw
    Write-Host $contents
    if ($contents -match 'SCRIPT ERROR|(?m)^ERROR:|Parse Error') { throw "$Name reported a runtime error." }
    if ($contents -notmatch 'Godot Engine') { throw "$Name engine startup was not confirmed." }
    Write-Host "WINDOWS PACKAGED STARTUP PASS: $Name"
}
Invoke-GameSmoke 'normal-game' @('--fresh')
$saveDir = Join-Path $env:APPDATA 'Godot/app_userdata/Chiefs of War'
New-Item -ItemType Directory -Force -Path $saveDir | Out-Null
$save = Join-Path $saveDir 'ancestral_hearth_v1.json'
[System.IO.File]::WriteAllText($save, 'campaign sentinel - do not overwrite')
Invoke-GameSmoke 'optional-practice' @('--combat-yard')
if ([System.IO.File]::ReadAllText($save) -ne 'campaign sentinel - do not overwrite') { throw 'Practice modified the campaign sentinel.' }
Write-Host 'WINDOWS PACKAGE VERIFIED: normal entry, practice entry, campaign isolation, path with spaces, external working directory.'
