# Contributing

Contributions are welcome when they improve the skill's clarity, safety, or debugging effectiveness.

## Guidelines

- Keep the skill focused on root-cause debugging.
- Prefer evidence-based instructions over motivational wording.
- Do not add instructions that encourage guessing, broad patching, or premature fixes.
- Do not add examples that print secrets, credentials, full environment dumps, private keys, cookies, session IDs, signing identities, or customer data.
- Keep `SKILL.md` concise enough to load well; move detailed scenario-specific material into supporting files.
- When adding a supporting file, reference it from `SKILL.md` with clear trigger conditions.

## Before opening a pull request

Run:

```bash
./scripts/validate.sh
./scripts/package.sh
```

Then test at least one direct invocation:

```text
/system-debug diagnose a failing test
```
