# CHANGELOG

## Optimized standalone version

This version keeps the core Superpowers systematic-debugging discipline while making the skill safer and more usable as a standalone artifact.

### Added

- Operating modes: Triage, Full Debug, and Incident Mitigation.
- Diagnostic safety rules for secrets, credentials, environment dumps, destructive commands, and temporary logs.
- Required Debugging Record template.
- Completion Criteria section.
- Trigger conditions for the supporting technique files.
- Structured escalation review after repeated failed fixes.

### Changed

- Replaced absolute “must have failing test” with “must have the smallest verification artifact.”
- Replaced “three failed fixes means architecture is wrong” with a broader escalation review.
- Rewrote unsafe diagnostic examples so they log presence/absence instead of secret values.
- Unified title and naming around `system-debug`.
- Reduced upstream session-specific metrics and promotional claims.
- Made defense-in-depth conditional on meaningful risk rather than defaulting to validation everywhere.

### Fixed

- Removed examples that could print environment variable values or secrets.
- Corrected phrasing and references that pointed to non-existent phase numbers.
- Ensured the expanded directory and zip package contain the same files.
