param(
    [ValidateSet("User", "Project")]
    [string]$Scope = "User",

    [string]$ProjectPath = (Get-Location).Path,

    [switch]$Force,

    [switch]$DryRun
)

$SkillName = "system-debug"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path $ScriptDir $SkillName
$SourceSkill = Join-Path $SourceDir "SKILL.md"

if (-not (Test-Path $SourceSkill)) {
    Write-Error "Source skill not found at $SourceSkill"
    exit 1
}

if ($Scope -eq "User") {
    $TargetBase = Join-Path $HOME ".claude\skills"
} else {
    $TargetBase = Join-Path $ProjectPath ".claude\skills"
}

$TargetDir = Join-Path $TargetBase $SkillName

Write-Host "Installing $SkillName"
Write-Host "Source: $SourceDir"
Write-Host "Target: $TargetDir"

if ($DryRun) {
    Write-Host "Dry run only; no files copied."
    exit 0
}

New-Item -ItemType Directory -Path $TargetBase -Force | Out-Null

if (Test-Path $TargetDir) {
    if (-not $Force) {
        Write-Error "$TargetDir already exists. Re-run with -Force to replace it."
        exit 1
    }
    Remove-Item -Recurse -Force $TargetDir
}

Copy-Item -Recurse -Path $SourceDir -Destination $TargetDir

$InstalledSkill = Join-Path $TargetDir "SKILL.md"
if (-not (Test-Path $InstalledSkill)) {
    Write-Error "Installation failed; SKILL.md missing at target."
    exit 1
}

if (-not (Select-String -Path $InstalledSkill -Pattern '^name: system-debug$' -Quiet)) {
    Write-Warning "Installed SKILL.md does not contain expected name: system-debug"
}

Write-Host "Installed successfully."
Write-Host "Try: /system-debug diagnose why this test is failing"
