# Publishing guide

This repository is prepared for public release as a standalone Skill.

## 1. Validate the skill

```bash
./scripts/validate.sh
```

The validator checks that:

- `system-debug/SKILL.md` exists
- frontmatter contains `name: system-debug`
- the required support files exist
- risky diagnostic patterns are not present in `SKILL.md`

## 2. Build release assets

```bash
./scripts/package.sh
```

Outputs:

```text
dist/system-debug.zip
dist/checksums.txt
```

The zip should have this structure:

```text
system-debug.zip
└── system-debug/
    ├── SKILL.md
    └── ...
```

## 3. Create a GitHub repository

Suggested repository name:

```text
system-debug-skill
```

Suggested commands:

```bash
git init
git add .
git commit -m "Initial release of system-debug skill"
git branch -M main
git remote add origin git@github.com:<owner>/system-debug-skill.git
git push -u origin main
```

## 4. Create a release

Suggested tag:

```text
v1.0.0
```

Suggested release title:

```text
system-debug v1.0.0
```

Attach these files:

```text
dist/system-debug.zip
dist/checksums.txt
```

Suggested release notes:

```markdown
# system-debug v1.0.0

Standalone root-cause debugging Skill for Claude Code, Claude.ai, and Agent Skills-compatible tools.

## Install

Claude Code personal install:

```bash
unzip system-debug.zip -d ~/.claude/skills
```

Claude Code project install:

```bash
mkdir -p .claude/skills
unzip system-debug.zip -d .claude/skills
```

Claude.ai: upload `system-debug.zip` as a custom Skill.

## Verify checksum

```bash
shasum -a 256 system-debug.zip
cat checksums.txt
```
```

## 5. Announce with the correct install target

Use `dist/system-debug.zip` for upload/download. Do not ask users to upload the full repository zip, because repository zips include docs, scripts, and folder nesting that are not the direct Skill package.
