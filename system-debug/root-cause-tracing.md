# Root-Cause Tracing

## Overview

Bugs often manifest deep in the call stack: a command runs in the wrong directory, a file is created in the wrong location, a database opens with the wrong path, or a worker receives corrupted state. The instinct is to fix where the error appears, but that usually treats the symptom.

**Core principle:** Trace backward through the call chain until you find the original trigger, then fix at the source.

## When to Use

Use this technique when:

- The error happens deep in execution rather than at the entry point.
- A stack trace shows a long call chain.
- Invalid data appears far from where it was created.
- A dangerous operation uses an unexpected path, id, config, credential state, or runtime state.
- You need to identify which test, request, job, event, or caller introduced the problem.

## Diagnostic Safety

Tracing often requires logs. Keep them safe:

- Do not print secrets, tokens, passwords, cookies, private keys, signing credentials, or full environment dumps.
- Log presence/absence, length, type, count, or redacted metadata instead of raw values.
- Redact usernames, customer identifiers, hostnames, and absolute paths when they are not needed.
- Log before dangerous operations, not only after they fail.
- Remove or gate temporary tracing logs after verification.

## The Tracing Process

### 1. Observe the Symptom

```text
Error: git init failed in /Users/<username>/project/packages/core
```

### 2. Find the Immediate Cause

Ask what code directly caused the symptom.

```typescript
await execFileAsync('git', ['init'], { cwd: projectDir });
```

### 3. Ask What Called This

Trace one level upward.

```text
WorktreeManager.createSessionWorktree(projectDir, sessionId)
  → called by Session.initializeWorkspace()
  → called by Session.create()
  → called by Project.create()
```

### 4. Track the Value at Each Layer

Ask what value was passed and whether it changed.

```text
projectDir = ''
empty string as cwd resolves to process.cwd()
process.cwd() is the source code directory
```

### 5. Find the Original Trigger

Keep tracing upward until you find where the bad value was introduced.

```typescript
const context = setupCoreTest();      // Initially returns { tempDir: '' }
Project.create('name', context.tempDir); // Accessed before beforeEach initialized tempDir
```

The source is not `git init`. The source is top-level initialization that reads a value before setup has run.

## Adding Stack Traces

When manual tracing is not enough, add temporary instrumentation immediately before the problematic operation.

```typescript
async function gitInit(directory: string) {
  const stack = new Error().stack;

  console.error('DEBUG git init context:', {
    directory: redactPath(directory),
    cwd: redactPath(process.cwd()),
    nodeEnv: process.env.NODE_ENV,
    stack,
  });

  await execFileAsync('git', ['init'], { cwd: directory });
}

function redactPath(path: string): string {
  return path.replace(process.env.HOME ?? '', '~');
}
```

In tests, `console.error()` is often more visible than a logger that may be suppressed.

Capture and inspect:

```bash
npm test 2>&1 | grep 'DEBUG git init context'
```

Analyze stack traces for:

- Test file names
- Caller line numbers
- Repeated call patterns
- The first layer where the value becomes invalid

## Finding Which Test Causes Pollution

If a test creates unwanted files, state, cache, database rows, or environment pollution, use `find-polluter.sh` from this directory.

Example:

```bash
./find-polluter.sh '.git' 'src/**/*.test.ts'
```

The script runs tests one by one and stops at the first test that creates the unwanted artifact.

## Example: Empty `projectDir`

Symptom: `.git` is created in a source-code directory.

Trace chain:

1. `git init` runs in `process.cwd()` because `cwd` received an empty string.
2. `WorktreeManager` was called with empty `projectDir`.
3. `Session.create()` passed the empty string.
4. Test setup read `context.tempDir` before `beforeEach` populated it.
5. `setupCoreTest()` initially exposed `{ tempDir: '' }`.

Root cause: initialization order allowed an empty value to escape.

Better fix:

- Fix at the source by making early access impossible, such as using a getter that throws before setup.
- Add targeted validation where different call paths could introduce the same invalid value.
- Add environment guards for dangerous operations in tests.

## Decision Rule

```text
Found immediate cause?
  → Can trace one level up?
      → Yes: trace upward and inspect the value.
      → No: add safe instrumentation.
  → Is this where the bad value originated?
      → No: keep tracing.
      → Yes: fix at the source.
```

Never stop at the first line that throws unless that line is also where the bad value was created.

## Stack Trace Tips

- Log before the dangerous operation.
- Include redacted path, current working directory, operation type, and stack.
- Do not include secrets or full environment dumps.
- In tests, use visible output channels.
- Prefer temporary instrumentation that can be removed after verification.
