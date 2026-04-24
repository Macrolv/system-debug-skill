# Upstream Source Note

This standalone skill was extracted from the Superpowers `systematic-debugging` skill.

- Upstream repository: `obra/superpowers`
- Upstream skill path: `skills/systematic-debugging/SKILL.md`
- License: MIT, included as `LICENSE`

## Why the raw upstream file is not embedded here

The optimized standalone version intentionally uses `SKILL.md` as the operational source of truth. The original upstream text contained session-specific examples and diagnostic shell snippets that were useful in context but are not ideal as standalone instructions.

This package keeps provenance information and the upstream license, while the operational instructions have been rewritten to be safer and more generally applicable.

## Main adaptation goals

- Remove dependency on the rest of the Superpowers bundle.
- Rename the standalone skill to `system-debug`.
- Add diagnostic safety rules, especially around secrets and environment variables.
- Add a required debugging record and completion criteria.
- Generalize verification beyond traditional failing tests.
- Replace mechanical “three failed fixes equals architecture problem” wording with structured escalation review.
