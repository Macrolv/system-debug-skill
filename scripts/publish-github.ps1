param(
  [string]$Owner = $env:GITHUB_OWNER,
  [string]$Repo = $(if ($env:GITHUB_REPO) { $env:GITHUB_REPO } else { "system-debug-skill" }),
  [ValidateSet("public", "private")]
  [string]$Visibility = "public",
  [string]$Tag = "v1.0.0",
  [string]$Title = "system-debug v1.0.0"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "git is required" }
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw "GitHub CLI 'gh' is required. Install it and run: gh auth login" }

gh auth status | Out-Null

if (-not $Owner) {
  $Owner = gh api user --jq .login
}
if (-not $Owner) { throw "Could not determine GitHub owner. Pass -Owner <username-or-org>." }

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

bash ./scripts/validate.sh
bash ./scripts/package.sh

$FullRepo = "$Owner/$Repo"

if (-not (Test-Path .git)) { git init }
git branch -M main

git add .
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) {
  git commit -m "Initial release of system-debug skill"
}

$repoExists = $true
try { gh repo view $FullRepo | Out-Null } catch { $repoExists = $false }

if ($repoExists) {
  git remote get-url origin *> $null
  if ($LASTEXITCODE -eq 0) { git remote set-url origin "git@github.com:$FullRepo.git" } else { git remote add origin "git@github.com:$FullRepo.git" }
} else {
  gh repo create $FullRepo "--$Visibility" --description "System-debug skill: root-cause software debugging workflow" --source=. --remote=origin --push
}

git push -u origin main

git rev-parse $Tag *> $null
if ($LASTEXITCODE -eq 0) { git tag -f $Tag } else { git tag $Tag }
git push origin $Tag --force

$Notes = @"
# system-debug $Tag

Initial public release of the system-debug skill.

## Install

### Claude Code user install

````bash
unzip system-debug.zip -d ~/.claude/skills
````

### Claude Code project install

````bash
mkdir -p .claude/skills
unzip system-debug.zip -d .claude/skills
````

## SHA-256

See ``checksums.txt``.
"@
$NotesFile = New-TemporaryFile
Set-Content -Path $NotesFile -Value $Notes -Encoding UTF8

$releaseExists = $true
try { gh release view $Tag --repo $FullRepo | Out-Null } catch { $releaseExists = $false }

if ($releaseExists) {
  gh release edit $Tag --repo $FullRepo --title $Title --notes-file $NotesFile
  gh release upload $Tag dist/system-debug.zip dist/checksums.txt --repo $FullRepo --clobber
} else {
  gh release create $Tag dist/system-debug.zip dist/checksums.txt --repo $FullRepo --title $Title --notes-file $NotesFile
}

Remove-Item $NotesFile -Force

Write-Host "Published: https://github.com/$FullRepo"
Write-Host "Release:   https://github.com/$FullRepo/releases/tag/$Tag"
