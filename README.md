# system-debug

A standalone Agent Skill / Claude Skill for systematic root-cause debugging.

`system-debug` helps AI coding assistants stop guessing, trace failures back to their source, verify one hypothesis at a time, and only claim success after a minimal verification artifact proves the fix.

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

## Quick install: Claude Code

### Personal install, all projects

```bash
unzip system-debug.zip -d ~/.claude/skills
```

Expected result:

```text
~/.claude/skills/system-debug/SKILL.md
```

### Project install, current repo only

```bash
mkdir -p .claude/skills
unzip system-debug.zip -d .claude/skills
```

Expected result:

```text
.claude/skills/system-debug/SKILL.md
```

### Install from cloned repo

```bash
git clone https://github.com/<owner>/system-debug-skill.git
cd system-debug-skill
./install.sh --user
```

For project-local install:

```bash
./install.sh --project /path/to/your/project
```

## Quick install: Claude.ai upload

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
├── install.sh             # macOS/Linux installer for Claude Code
├── install.ps1            # Windows PowerShell installer for Claude Code
├── scripts/
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
