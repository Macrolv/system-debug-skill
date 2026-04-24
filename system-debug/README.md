# system-debug skill

`system-debug` is a standalone Agent Skill for systematic root-cause debugging.

It helps an AI coding assistant avoid guess-and-patch behavior by enforcing evidence gathering, root-cause tracing, one-hypothesis-at-a-time testing, a minimal verification artifact, and verified resolution before claiming a bug is fixed.

## Skill contents

- `SKILL.md` — main skill instructions and metadata
- `root-cause-tracing.md` — trace failures from symptom to source
- `defense-in-depth.md` — add boundary checks for high-risk failures
- `condition-based-waiting.md` — replace arbitrary sleeps with condition-based waits
- `condition-based-waiting-example.ts` — TypeScript example helper
- `find-polluter.sh` — helper for finding tests that create unwanted files/state
- `UPSTREAM-SKILL.md` — provenance and adaptation notes
- `CHANGELOG.md` — release history
- `LICENSE` — MIT license

## Manual invocation

Use the slash command generated from the skill name:

```text
/system-debug diagnose this CI failure
```

Or ask naturally:

```text
Use system-debug to find the root cause before changing code.
```
