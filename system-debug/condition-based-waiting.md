# Condition-Based Waiting

## Overview

Flaky tests often guess at timing with arbitrary delays. This creates race conditions where tests pass on fast machines but fail under load, in CI, or when run in parallel.

**Core principle:** Wait for the actual condition you care about, not a guess about how long it might take.

## When to Use

Use condition-based waiting when:

- Tests use arbitrary delays such as `setTimeout`, `sleep`, `time.sleep()`, or fixed retry delays.
- Tests pass locally but fail in CI.
- Tests fail under parallelism, load, or slower hardware.
- The code waits for async operations, events, files, jobs, messages, or state transitions.
- The test is checking eventual state but sleeps before reading it.

Do not replace timing intentionally under test, such as debounce duration, throttle interval, retry backoff, or timeout behavior. In those cases, document why time itself is the behavior being tested.

## Core Pattern

```typescript
// Before: guessing at timing
await new Promise((resolve) => setTimeout(resolve, 50));
const result = getResult();
expect(result).toBeDefined();

// After: waiting for the condition
await waitFor(() => getResult() !== undefined, 'result to be defined');
const result = getResult();
expect(result).toBeDefined();
```

## Quick Patterns

| Scenario | Pattern |
|----------|---------|
| Wait for event | `waitFor(() => events.find(e => e.type === 'DONE'), 'DONE event')` |
| Wait for state | `waitFor(() => machine.state === 'ready', 'machine ready')` |
| Wait for count | `waitFor(() => items.length >= 5, 'at least 5 items')` |
| Wait for file | `waitFor(() => fs.existsSync(path), 'file exists')` |
| Complex condition | `waitFor(() => obj.ready && obj.value > 10, 'object ready with value')` |

## Generic Implementation

```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000,
  intervalMs = 10
): Promise<T> {
  const startTime = Date.now();

  while (true) {
    const result = condition();
    if (result) return result;

    if (Date.now() - startTime > timeoutMs) {
      throw new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`);
    }

    await new Promise((resolve) => setTimeout(resolve, intervalMs));
  }
}
```

See `condition-based-waiting-example.ts` for domain-specific helpers such as `waitForEvent`, `waitForEventCount`, and `waitForEventMatch`.

## Common Mistakes

| Mistake | Better approach |
|---------|-----------------|
| Polling too fast, such as every 1ms | Poll at a modest interval, such as 10ms or a domain-appropriate interval |
| No timeout | Always include a timeout with a clear error message |
| Stale data | Read fresh state inside the polling function |
| Vague timeout errors | Include the condition description and observed state when useful |
| Sleeping after the event already happened | Wait for the event or state transition directly |
| Retrying the action instead of observing state | Trigger once, then wait for the expected condition |

## When an Arbitrary Timeout Is Correct

An arbitrary-looking delay may be correct when time itself is the behavior being tested.

```typescript
// Tool emits progress every 100ms.
// First wait for the tool to start, then wait two documented ticks.
await waitForEvent(manager, 'TOOL_STARTED');
await new Promise((resolve) => setTimeout(resolve, 200));
expect(progressEvents.length).toBeGreaterThanOrEqual(2);
```

Requirements:

1. First wait for a triggering condition.
2. Base the delay on known behavior, not a guess.
3. Comment why the delay is necessary.
4. Keep the delay as small and deterministic as possible.

## Debugging Flaky Tests

When a flaky test uses sleeps:

1. Identify the actual condition the test needs.
2. Replace sleep with a wait for that condition.
3. Add a clear timeout error.
4. Run the test repeatedly and under CI-like conditions.
5. Confirm the test still fails when the condition is genuinely absent.

Condition-based waiting should make real failures clearer, not hide them.
