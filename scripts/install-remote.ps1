param(
    [ValidateSet("User", "Project")]
    [string]$Scope = "User",

    [string]$ProjectPath = (Get-Location).Path,

    [switch]$Force,

    [switch]$DryRun,

    [string]$Repository = $(if ($env:SYSTEM_DEBUG_REPOSITORY) { $env:SYSTEM_DEBUG_REPOSITORY } else { "Macrolv/system-debug-skill" }),

    [string]$Ref = $(if ($env:SYSTEM_DEBUG_REF) { $env:SYSTEM_DEBUG_REF } else { "main" })
)

$ErrorActionPreference = "Stop"
$SkillName = "system-debug"

if ($Scope -eq "User") {
    $TargetBase = Join-Path $HOME ".claude\skills"
} else {
    $TargetBase = Join-Path $ProjectPath ".claude\skills"
}

$TargetDir = Join-Path $TargetBase $SkillName
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("system-debug-install-" + [System.Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null

try {
    $ZipPath = Join-Path $TempRoot "source.zip"
    $ArchiveUrl = "https://github.com/$Repository/archive/refs/heads/$Ref.zip"

    try {
        Invoke-WebRequest -UseBasicParsing -Uri $ArchiveUrl -OutFile $ZipPath
    } catch {
        $ArchiveUrl = "https://github.com/$Repository/archive/refs/tags/$Ref.zip"
        Invoke-WebRequest -UseBasicParsing -Uri $ArchiveUrl -OutFile $ZipPath
    }

    $ExtractPath = Join-Path $TempRoot "src"
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

    $SourceSkill = Get-ChildItem -Path $ExtractPath -Recurse -Filter "SKILL.md" |
        Where-Object { $_.FullName -match "[\\/]system-debug[\\/]SKILL\.md$" } |
        Select-Object -First 1

    if (-not $SourceSkill) {
        throw "Could not find system-debug/SKILL.md in downloaded archive."
    }

    $SourceDir = Split-Path -Parent $SourceSkill.FullName

    if (-not (Select-String -Path $SourceSkill.FullName -Pattern '^name: system-debug$' -Quiet)) {
        throw "Downloaded SKILL.md does not declare name: system-debug"
    }

    Write-Host "Installing $SkillName from $Repository@$Ref"
    Write-Host "Source: $SourceDir"
    Write-Host "Target: $TargetDir"

    if ($DryRun) {
        Write-Host "Dry run only; no files copied."
        exit 0
    }

    New-Item -ItemType Directory -Path $TargetBase -Force | Out-Null

    if (Test-Path $TargetDir) {
        if (-not $Force) {
            throw "$TargetDir already exists. Re-run with -Force to replace it."
        }
        Remove-Item -Recurse -Force $TargetDir
    }

    Copy-Item -Recurse -Path $SourceDir -Destination $TargetDir

    Write-Host "Installed successfully."
    Write-Host "Installed path: $TargetDir"
    Write-Host "Try: /system-debug diagnose why this test is failing"
}
finally {
    if (Test-Path $TempRoot) {
        Remove-Item -Recurse -Force $TempRoot -ErrorAction SilentlyContinue
    }
}
