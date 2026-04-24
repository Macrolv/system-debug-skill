// Condition-based waiting utilities.
// Use these patterns to replace arbitrary sleeps in flaky async tests.

export interface TestEvent {
  type: string;
  data?: unknown;
}

export interface EventSource {
  getEvents(): TestEvent[];
}

/**
 * Generic condition polling helper.
 */
export async function waitFor<T>(
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

/**
 * Wait for a specific event type to appear.
 */
export function waitForEvent(
  source: EventSource,
  eventType: string,
  timeoutMs = 5000
): Promise<TestEvent> {
  return waitFor(
    () => source.getEvents().find((event) => event.type === eventType),
    `${eventType} event`,
    timeoutMs
  );
}

/**
 * Wait for a specific number of events of a given type.
 */
export function waitForEventCount(
  source: EventSource,
  eventType: string,
  count: number,
  timeoutMs = 5000
): Promise<TestEvent[]> {
  return waitFor(
    () => {
      const matchingEvents = source.getEvents().filter((event) => event.type === eventType);
      return matchingEvents.length >= count ? matchingEvents : undefined;
    },
    `${count} ${eventType} events`,
    timeoutMs
  );
}

/**
 * Wait for an event matching a custom predicate.
 */
export function waitForEventMatch(
  source: EventSource,
  predicate: (event: TestEvent) => boolean,
  description: string,
  timeoutMs = 5000
): Promise<TestEvent> {
  return waitFor(
    () => source.getEvents().find(predicate),
    description,
    timeoutMs
  );
}

// Usage pattern:
//
// Before (flaky):
// const operation = service.startAsyncWork();
// await new Promise((resolve) => setTimeout(resolve, 300)); // Hope work has started.
// service.cancel();
// await operation;
// await new Promise((resolve) => setTimeout(resolve, 50));  // Hope results arrived.
// expect(results.length).toBe(2);
//
// After (deterministic):
// const operation = service.startAsyncWork();
// await waitForEventCount(eventSource, 'WORK_STARTED', 2);
// service.cancel();
// await operation;
// await waitForEventCount(eventSource, 'WORK_RESULT', 2);
// expect(results.length).toBe(2);
