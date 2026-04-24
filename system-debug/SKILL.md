---
name: system-debug
description: Root-cause software debugging workflow. Use before changing code or configuration for bugs, test failures, flaky tests, regressions, build failures, performance issues, or integration failures. Requires evidence gathering, one-hypothesis-at-a-time testing, a minimal verification artifact, and verified resolution before claiming success.
---

# System Debug: Systematic Root-Cause Debugging

> Standalone extraction of the Superpowers `systematic-debugging` skill, optimized for use without the rest of the Superpowers bundle.

## Overview

Random fixes waste time and create new bugs. Quick patches often mask the underlying problem.

**Core principle:** Find the root cause before attempting fixes. Symptom fixes are failures unless they are explicitly labeled as temporary containment.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```text
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you have not completed root-cause investigation, you cannot claim to know the fix.

## Operating Modes

Use the lightest mode that fits the user's request, but do not skip evidence.

### Triage Mode

Use when the user asks to understand an error, warning, stack trace, failing command, or suspicious behavior.

Goal: explain what is known, identify likely investigation paths, and recommend evidence to collect. Do not patch unless root cause is established.

### Full Debug Mode

Use when the user wants the issue fixed, code changed, configuration changed, or a patch proposed.

Goal: complete the four debugging phases before proposing or applying a fix.

### Incident Mitigation Mode

Use when production, data integrity, security, availability, or user-impact risk requires immediate containment.

Goal: apply only reversible, narrowly scoped containment first; clearly label it as mitigation; preserve diagnostics; then continue root-cause investigation.

## When to Use

Use for technical issues such as:

- Test failures
- Bugs in production or development
- Unexpected behavior
- Regressions
- Performance problems
- Build failures
- CI/CD failures
- Integration issues
- Flaky tests
- Data, state, path, permission, cache, dependency, or environment mismatches

Use this especially when:

- You are under time pressure
- A “quick fix” seems obvious
- You have already tried a fix
- A previous fix did not work
- The issue crosses multiple components
- You do not fully understand the failure

Do not turn every tiny explanation request into a long ritual. If the user only wants an explanation, use Triage Mode. If you are changing code or configuration, use Full Debug Mode.

## Diagnostic Safety

Debugging must not leak secrets or create new damage.

When adding diagnostics:

- Never print secrets, tokens, passwords, cookies, private keys, session IDs, signing identities, credentials, or full environment dumps.
- Log presence/absence instead of values.
- Use length, type, count, source, or a short safe fingerprint only when necessary.
- Redact file paths, usernames, customer identifiers, and hostnames when they are not needed.
- Remove or gate temporary diagnostic logs after verification.
- Avoid destructive commands unless the user explicitly approved them or the operation is safely scoped to a test environment.
- Prefer dry-runs, read-only checks, and isolated reproductions before touching real data.

Safe shell pattern:

```bash
show_var_state() {
  local name="$1"
  if [ -n "${!name:-}" ]; then
    echo "$name=SET"
  else
    echo "$name=UNSET"
  fi
}

show_var_state IDENTITY
show_var_state API_TOKEN
```

If you must confirm that a value changed, log safe metadata only:

```bash
if [ -n "${IDENTITY:-}" ]; then
  echo "IDENTITY=SET length=${#IDENTITY}"
else
  echo "IDENTITY=UNSET"
fi
```

Never dump full environment variables or print sensitive variable values in shared logs.

## Required Debugging Record

For non-trivial issues, maintain this record before proposing or applying a fix. It may be shown to the user or used internally, depending on the interaction.

```text
Symptom:
Reproduction status:
Evidence gathered:
Relevant recent changes:
Data-flow or control-flow trace:
Working reference or comparison:
Root cause:
Hypotheses rejected:
Minimal verification artifact:
Proposed fix:
Verification results:
Remaining uncertainty:
```

Do not claim the issue is fixed unless `Root cause`, `Minimal verification artifact`, and `Verification results` are filled in.

## The Four Phases

Complete each phase before proceeding to the next in Full Debug Mode.

### Phase 1: Root-Cause Investigation

Before attempting any fix:

#### 1. Read Error Messages Carefully

- Do not skip errors or warnings.
- Read stack traces completely.
- Note line numbers, file paths, error codes, versions, and timestamps.
- Separate primary errors from downstream noise.

#### 2. Reproduce Consistently

- Can you trigger it reliably?
- What are the exact steps?
- Does it happen every time?
- Does it depend on OS, environment, time, load, order, cache, network, permissions, or data shape?
- If it is not reproducible, gather more data instead of guessing.

#### 3. Check Recent Changes

- What changed that could cause this?
- Inspect git diff and recent commits.
- Check dependency, lockfile, config, environment, schema, feature flag, permission, credential, and infrastructure changes.
- Compare failing and passing environments.

#### 4. Gather Evidence in Multi-Component Systems

When the system has multiple components, such as CI → build → signing, API → service → database, frontend → backend → cache, or queue → worker → storage, instrument boundaries before proposing fixes.

For each component boundary:

```text
- Log what type/shape/status of data enters the component.
- Log what type/shape/status of data exits the component.
- Verify environment/config propagation without printing secret values.
- Check state at each layer.
- Run once to gather evidence showing where the failure begins.
- Then investigate the failing component specifically.
```

Safe multi-layer example:

```bash
# Layer 1: Workflow
printf '=== Workflow inputs ===\n'
show_var_state IDENTITY
show_var_state SIGNING_CERT

# Layer 2: Build script
printf '=== Build script environment ===\n'
show_var_state IDENTITY
printf 'BUILD_MODE=%s\n' "${BUILD_MODE:-unset}"

# Layer 3: Signing context
printf '=== Keychain state ===\n'
security list-keychains
security find-identity -v | sed -E 's/\"[^\"]+\"/"<redacted>"/g'

# Layer 4: Actual signing
codesign --sign "$IDENTITY" --verbose=4 "$APP"
```

This type of instrumentation reveals where the chain breaks, for example: secrets → workflow works, workflow → build fails.

#### 5. Trace Data Flow

When the error appears deep in a call stack, trace backward.

Use `root-cause-tracing.md` when:

- The error appears deep in execution.
- Bad data appears far from its origin.
- A dangerous operation uses an unexpected path, id, config, or state.
- You need to know which caller, test, request, or job introduced the bad value.

Quick version:

- Where does the bad value appear?
- What called this with the bad value?
- What value was passed at each layer?
- Keep tracing upward until you find the original trigger.
- Fix at the source, not at the symptom.

### Phase 2: Pattern Analysis

Find the pattern before fixing.

#### 1. Find Working Examples

- Locate similar working code in the same codebase.
- Find the closest known-good implementation.
- Prefer local patterns over generic assumptions.

#### 2. Compare Against References

- If implementing a pattern, read the reference implementation completely.
- Understand the whole path, not just the line that looks relevant.
- Include tests, setup, teardown, configuration, and error handling.

#### 3. Identify Differences

- What is different between working and broken?
- List every difference, however small.
- Do not assume “that cannot matter” until evidence supports it.

#### 4. Understand Dependencies

- What other components does this need?
- What settings, config, schema, state, permissions, dependencies, or environment are assumed?
- Which assumptions are violated in the failing case?

### Phase 3: Hypothesis and Testing

Use the scientific method.

#### 1. Form One Specific Hypothesis

State it clearly:

```text
I think X is the root cause because evidence Y shows Z.
```

A useful hypothesis is specific enough to be falsified.

#### 2. Test Minimally

- Make the smallest possible change to test the hypothesis.
- Change one variable at a time.
- Do not bundle fixes, refactors, cleanup, or unrelated improvements.

#### 3. Verify Before Continuing

- If evidence confirms the hypothesis, proceed to Phase 4.
- If evidence rejects the hypothesis, record it and form a new one.
- Do not add more patches on top of a failed guess.

#### 4. When You Do Not Know

- Say “I do not understand X yet.”
- Gather more evidence.
- Read source, docs, tests, logs, or relevant references.
- Ask the human partner only when the missing information cannot be discovered from available context.

### Phase 4: Implementation and Verification

Fix the root cause, not the symptom.

#### 1. Create the Smallest Verification Artifact

Before fixing, create the smallest artifact that proves the failure and can prove the fix.

Use the best feasible option:

- Automated failing test
- Minimal reproduction script
- Captured failing command
- Diagnostic assertion
- Log-based before/after evidence
- Benchmark baseline for performance bugs
- Reproduction checklist for environment-specific failures

Prefer an automated failing test when practical. If no test framework or deterministic reproduction exists, use the smallest repeatable evidence artifact available.

#### 2. Implement One Fix

- Address the identified root cause.
- Make one conceptual change at a time.
- Avoid “while I am here” changes.
- Avoid bundled refactors unless the root cause is the structure itself.

#### 3. Verify the Fix

- Does the verification artifact fail before and pass after?
- Do relevant existing tests pass?
- Did the original symptom disappear?
- Did the fix create new errors, regressions, performance issues, or unsafe behavior?
- Is temporary diagnostic instrumentation removed, gated, or documented?

#### 4. If the Fix Does Not Work

Stop normal patching.

- Count how many fix attempts have failed.
- If fewer than 3: return to Phase 1 with the new evidence.
- If 3 or more: enter escalation review before another fix attempt.

#### 5. Escalation Review After Three Failed Fixes

Three failed fixes do not automatically prove the architecture is wrong, but they do prove normal patching is no longer trustworthy.

Escalation review must decide whether the issue is:

- Incomplete root-cause analysis
- Unstable or incorrect reproduction
- Hidden dependency or environment mismatch
- Multiple independent bugs
- Wrong abstraction or design flaw
- Test harness, fixture, or mock pollution
- Race condition or timing problem
- External service, version, or configuration drift

Only after this review should you attempt another fix. Discuss the findings with the human partner when possible.

## Red Flags: Stop and Return to Phase 1

If you catch yourself thinking any of these, stop:

- “Quick fix for now, investigate later.”
- “Just try changing X and see if it works.”
- “Add multiple changes, then run tests.”
- “Skip the test; I will manually verify.”
- “It is probably X, let me fix that.”
- “I do not fully understand this, but this might work.”
- “Pattern says X, but I will adapt it differently.”
- “Here are the main problems,” followed by fixes without investigation.
- “One more fix attempt,” after repeated failed fixes.
- Proposing solutions before tracing data flow.
- Each fix reveals a new problem in a different place.

If three or more fixes have failed, enter escalation review.

## Your Human Partner's Signals You're Doing It Wrong

Watch for these redirections:

- “Is that not happening?” — you assumed without verifying.
- “Will it show us...?” — you should have added evidence gathering.
- “Stop guessing.” — you are proposing fixes without understanding.
- “Ultrathink this.” — question fundamentals, not just symptoms.
- “We are stuck?” — your current approach is not working.

When you see these, stop and return to Phase 1 or escalation review.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| “Issue is simple; I do not need process.” | Simple issues have root causes too. Use a lightweight version, not guessing. |
| “Emergency; no time for process.” | Contain if needed, then investigate. Guessing often extends incidents. |
| “Just try this first, then investigate.” | The first fix sets the pattern. Start with evidence. |
| “I will write the test after confirming the fix works.” | Without a verification artifact, you cannot prove the fix. |
| “Multiple fixes at once saves time.” | You cannot isolate what worked, and you may introduce new bugs. |
| “The reference is too long; I will adapt the pattern.” | Partial understanding often creates mismatched behavior. |
| “I see the problem; let me fix it.” | Seeing a symptom is not the same as understanding the root cause. |
| “One more fix attempt.” | Repeated failed fixes require escalation review, not another guess. |

## Supporting Techniques

These files are part of this skill and should be used when their trigger conditions match.

### `root-cause-tracing.md`

Use when:

- The error appears deep in a stack trace.
- Bad data appears far from its source.
- A dangerous operation uses an unexpected path, id, config, or state.
- You need to identify which caller, test, request, or job introduced the problem.

### `defense-in-depth.md`

Use when:

- Invalid data crosses trust boundaries.
- The bug could cause destructive operations, data loss, security exposure, or persistent corruption.
- Multiple call paths can reach the same dangerous operation.
- A single validation point can be bypassed by mocks, refactors, or alternate entry points.

Do not add redundant validation everywhere by default. Add checks where they prevent materially different failure modes.

### `condition-based-waiting.md`

Use when:

- Tests use `sleep`, `setTimeout`, polling loops, retry loops, or arbitrary delays.
- Flaky tests fail under load, parallelism, or CI.
- An async operation is being guessed at by time rather than observed by condition.

## Quick Reference

| Phase | Key activities | Success criteria |
|-------|----------------|------------------|
| 1. Root cause | Read errors, reproduce, check changes, gather evidence, trace data | You understand what failed, where it first failed, and why |
| 2. Pattern | Find working examples, compare references, map differences | You know what correct behavior looks like |
| 3. Hypothesis | State one falsifiable theory, test minimally | Hypothesis is confirmed or rejected by evidence |
| 4. Implementation | Create verification artifact, apply one fix, verify | Failure is proven resolved without regressions |

## Completion Criteria

You may claim the issue is fixed only when:

- The root cause is identified.
- The fix addresses the root cause, not only the symptom.
- The minimal verification artifact fails before and passes after, or the best feasible before/after evidence is documented.
- Relevant tests, commands, or checks pass.
- Temporary diagnostics are removed, gated, or intentionally retained with justification.
- Remaining uncertainty is stated honestly.

## When the Process Reveals No Local Root Cause

If systematic investigation shows the issue is environmental, timing-dependent, external, or intermittent:

1. Document what you investigated.
2. Document what evidence ruled out local causes.
3. Implement appropriate handling such as retry, timeout, clearer error message, fallback, monitoring, or alerting.
4. Add diagnostics for future investigation.
5. Avoid claiming certainty beyond the evidence.

Many “no root cause” cases are incomplete investigations. Treat this conclusion carefully.
