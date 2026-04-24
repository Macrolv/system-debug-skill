# system-debug

A standalone Agent Skill / Claude Skill for systematic root-cause debugging.

`system-debug` helps AI coding assistants stop guessing, trace failures back to their source, verify one hypothesis at a time, and only claim success after a minimal verification artifact proves the fix.

## Install with one command

### macOS / Linux / WSL

Personal install for all Claude Code projects:

```bash
curl -fsSL https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.sh | bash
```

Project-local install, run from your project root:

```bash
curl -fsSL https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.sh | bash -s -- --project .
```

Replace an existing install:

```bash
curl -fsSL https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.sh | bash -s -- --user --force
```

Install a specific branch or tag:

```bash
curl -fsSL https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.sh | bash -s -- --ref v1.0.0 --force
```

### Windows PowerShell

Personal install for all Claude Code projects:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.ps1'; $p=Join-Path $env:TEMP 'install-system-debug.ps1'; Invoke-WebRequest -UseBasicParsing $u -OutFile $p; & $p -Scope User"
```

Project-local install:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.ps1'; $p=Join-Path $env:TEMP 'install-system-debug.ps1'; Invoke-WebRequest -UseBasicParsing $u -OutFile $p; & $p -Scope Project -ProjectPath 'C:\path\to\project'"
```

Replace an existing install:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "$u='https://raw.githubusercontent.com/Macrolv/system-debug-skill/main/scripts/install-remote.ps1'; $p=Join-Path $env:TEMP 'install-system-debug.ps1'; Invoke-WebRequest -UseBasicParsing $u -OutFile $p; & $p -Scope User -Force"
```

Verify installation:

```text
~/.claude/skills/system-debug/SKILL.md                  # macOS/Linux personal install
.claude/skills/system-debug/SKILL.md                    # project install
%USERPROFILE%\.claude\skills\system-debug\SKILL.md    # Windows personal install
```

Then try:

```text
/system-debug diagnose why this test is failing
```

## What this skill is for

Use it for:

- Bugs and regressions
- Test failures and flaky tests
- Build, CI/CD, signing, deployment, and integration failures
- Performance investigations
- Configuration, environment, cache, permission, dependency, and state mismatches
- Cases where repeated quick fixes have failed

The skill supports three modes:

- **Triage Mode** — understand an error or failure without patching prematurely.
- **Full Debug Mode** — complete root-cause investigation before proposing or applying a fix.
- **Incident Mitigation Mode** — apply reversible containment for urgent production/data/security risk, then continue the root-cause investigation.

## Install from release zip

Download `system-debug.zip` from the latest GitHub Release.

### Claude Code: personal install

```bash
unzip system-debug.zip -d ~/.claude/skills
```

Expected result:

```text
~/.claude/skills/system-debug/SKILL.md
```

### Claude Code: project install

```bash
mkdir -p .claude/skills
unzip system-debug.zip -d .claude/skills
```

Expected result:

```text
.claude/skills/system-debug/SKILL.md
```

### Claude.ai upload

Upload `system-debug.zip` as a custom Skill. The zip is packaged with the required root folder:

```text
system-debug.zip
└── system-debug/
    ├── SKILL.md
    ├── root-cause-tracing.md
    ├── defense-in-depth.md
    └── ...
```

After uploading, enable the skill and test it with:

```text
Use system-debug to diagnose this failing test before changing code.
```

## Install from cloned repo

```bash
git clone https://github.com/Macrolv/system-debug-skill.git
cd system-debug-skill
./install.sh --user
```

For project-local install:

```bash
./install.sh --project /path/to/your/project
```

Windows PowerShell:

```powershell
.\install.ps1 -Scope User
```

## Manual install by copy

Copy the `system-debug/` folder into one of these locations:

```text
~/.claude/skills/system-debug/          # personal Claude Code skill
.claude/skills/system-debug/            # project Claude Code skill
.github/skills/system-debug/            # Agent Skills-compatible repo layout, e.g. VS Code Copilot
```

Make sure `SKILL.md` remains directly inside the `system-debug/` folder.

## Usage examples

```text
/system-debug why is this Jest test flaky?
```

```text
Use system-debug. CI is failing on codesign, and I want root cause before any patch.
```

```text
Use system-debug triage mode to explain this stack trace and what evidence to collect.
```

## Safety

This skill includes diagnostic safety rules. It instructs the assistant not to print secrets, tokens, cookies, private keys, credentials, signing identities, or full environment dumps, and to prefer presence/absence, lengths, counts, or safe fingerprints when diagnostics are needed.

Always review any downloaded Skill before enabling it, especially if it includes scripts.

## Validate and package

From the repository root:

```bash
./scripts/validate.sh
./scripts/package.sh
```

The package script creates:

```text
dist/system-debug.zip
dist/checksums.txt
```

## Repository layout

```text
system-debug-skill/
├── system-debug/          # actual skill folder to install
│   ├── SKILL.md
│   └── ...
├── install.sh             # macOS/Linux local installer for Claude Code
├── install.ps1            # Windows PowerShell local installer for Claude Code
├── scripts/
│   ├── install-remote.sh  # macOS/Linux one-line installer
│   ├── install-remote.ps1 # Windows one-line installer
│   ├── validate.sh
│   └── package.sh
├── examples/
│   └── prompts.md
├── INSTALL.md
├── PUBLISHING.md
├── SECURITY.md
├── CONTRIBUTING.md
├── CHANGELOG.md
└── LICENSE
```

## Provenance

This standalone skill was extracted and adapted from `obra/superpowers`, original skill path `skills/systematic-debugging/`. The adaptation removes bundle-specific dependencies and adds safer standalone behavior.

## License

MIT. See `LICENSE`.
