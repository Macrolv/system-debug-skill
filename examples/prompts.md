# Example prompts

## Direct invocation

```text
/system-debug diagnose why this test is failing and do not patch until root cause is established
```

## Natural invocation

```text
Use system-debug. The CI build fails only on macOS runners. Find the root cause before proposing a fix.
```

## Triage mode

```text
Use system-debug triage mode. Explain what this stack trace tells us and what evidence we should collect next.
```

## Flaky test

```text
Use system-debug for this flaky Playwright test. Replace timing guesses with condition-based evidence.
```

## Repeated failed fixes

```text
Use system-debug escalation review. We tried three fixes and the failure moved each time.
```
