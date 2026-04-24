# Defense-in-Depth Validation

## Overview

When a bug is caused by invalid data, a single validation check can feel sufficient. Sometimes it is. But if the bad value can cross trust boundaries, reach dangerous operations, or enter through multiple paths, one check can be bypassed by refactors, mocks, alternate entry points, or future changes.

**Core principle:** Add validation at the boundaries that prevent materially different failure modes. Make serious bugs structurally hard to reproduce, not merely patched in one path.

## When to Use

Use defense-in-depth when:

- Invalid data crosses API, process, filesystem, database, network, job, or trust boundaries.
- The bug could cause destructive operations, data loss, security exposure, account impact, or persistent corruption.
- Multiple call paths can reach the same dangerous operation.
- Mocks, tests, or alternate entry points can bypass the first validation point.
- A fix at only one layer would leave the same bad state possible elsewhere.

Do not add redundant validation everywhere by default. Use it when each layer protects a distinct boundary or failure mode.

## The Layer Model

### Layer 1: Entry Point Validation

Purpose: reject obviously invalid input at the API or user-facing boundary.

```typescript
function createProject(name: string, workingDirectory: string) {
  if (!workingDirectory || workingDirectory.trim() === '') {
    throw new Error('workingDirectory cannot be empty');
  }
  if (!existsSync(workingDirectory)) {
    throw new Error(`workingDirectory does not exist: ${redactPath(workingDirectory)}`);
  }
  if (!statSync(workingDirectory).isDirectory()) {
    throw new Error(`workingDirectory is not a directory: ${redactPath(workingDirectory)}`);
  }

  // ... proceed
}
```

### Layer 2: Business Logic Validation

Purpose: ensure data makes sense for this operation, not merely that it exists.

```typescript
function initializeWorkspace(projectDir: string, sessionId: string) {
  if (!projectDir) {
    throw new Error('projectDir is required for workspace initialization');
  }
  if (!sessionId) {
    throw new Error('sessionId is required for workspace initialization');
  }

  // ... proceed
}
```

### Layer 3: Environment or Context Guard

Purpose: prevent dangerous operations in contexts where they should never happen.

```typescript
async function gitInit(directory: string) {
  if (process.env.NODE_ENV === 'test') {
    const normalized = normalize(resolve(directory));
    const tmpDir = normalize(resolve(tmpdir()));

    if (!normalized.startsWith(tmpDir)) {
      throw new Error(
        `Refusing git init outside temp dir during tests: ${redactPath(directory)}`
      );
    }
  }

  // ... proceed
}
```

### Layer 4: Safe Debug Instrumentation

Purpose: capture enough context for future forensics without leaking secrets.

```typescript
async function gitInit(directory: string) {
  logger.debug('About to git init', {
    directory: redactPath(directory),
    cwd: redactPath(process.cwd()),
    nodeEnv: process.env.NODE_ENV,
    stack: new Error().stack,
  });

  // ... proceed
}
```

Do not log tokens, passwords, cookies, private keys, raw credentials, or full environment dumps.

## Applying the Pattern

After you find the root cause:

1. Trace the data flow: where did the bad value originate and where is it used?
2. Map trust boundaries and dangerous operations.
3. Decide which boundaries need validation.
4. Add the fewest checks that prevent distinct failure modes.
5. Test each important layer or document why it is covered by existing tests.
6. Verify that validation errors are clear and safe to show in logs.

## Example: Empty `projectDir`

Bug: an empty `projectDir` allowed `git init` to run in the current source-code directory.

Data flow:

1. Test setup produced an empty string.
2. `Project.create(name, '')` accepted it.
3. `WorkspaceManager.createWorkspace('')` propagated it.
4. `git init` interpreted the empty `cwd` as `process.cwd()`.

Useful layers:

- Entry point: `Project.create()` rejects empty or invalid directories.
- Business logic: workspace creation requires a non-empty project directory.
- Environment guard: tests refuse to run `git init` outside temporary directories.
- Safe instrumentation: logs redacted path and stack before dangerous operations.

The goal is not “validation everywhere.” The goal is “no realistic path lets this bad value reach the dangerous operation silently.”

## Anti-Patterns

Avoid these:

- Adding many identical checks that do not protect different boundaries.
- Logging raw secrets or full environment variables to debug validation.
- Hiding the root cause with broad fallback behavior.
- Turning validation into unrelated refactoring.
- Adding validation before you know the root cause.

## Key Insight

A single validation point is enough only when there is a single meaningful entry path and low consequence. Multiple layers are justified when different boundaries can independently prevent meaningful harm.
