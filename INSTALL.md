# Installation

## Install from release zip

Download `system-debug.zip` from the latest release.

### Claude Code: personal install

```bash
unzip system-debug.zip -d ~/.claude/skills
```

Check:

```bash
test -f ~/.claude/skills/system-debug/SKILL.md && echo "installed"
```

### Claude Code: project install

Run from your project root:

```bash
mkdir -p .claude/skills
unzip system-debug.zip -d .claude/skills
```

Check:

```bash
test -f .claude/skills/system-debug/SKILL.md && echo "installed"
```

### Claude.ai

Upload `system-debug.zip` as a custom Skill, then enable it in the Skills settings.

## Install from cloned repository

```bash
git clone https://github.com/<owner>/system-debug-skill.git
cd system-debug-skill
./install.sh --user
```

Project-local install:

```bash
./install.sh --project /path/to/project
```

Overwrite an existing install:

```bash
./install.sh --user --force
```

Dry run:

```bash
./install.sh --user --dry-run
```

## Windows PowerShell

Personal install:

```powershell
.\install.ps1 -Scope User
```

Project install:

```powershell
.\install.ps1 -Scope Project -ProjectPath C:\path\to\project
```

Overwrite existing install:

```powershell
.\install.ps1 -Scope User -Force
```

## Test invocation

```text
/system-debug diagnose why this test is failing
```

or:

```text
Use system-debug to find the root cause before changing code.
```
