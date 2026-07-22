## Context

The 2026-07-22 `All` suite run reported 22 failed tests and four unmatched
groups. Focused UHT tests passed, so this change does not alter the current UHT
binding consolidation. The failures instead span an AngelScript SDK builder
diagnostic crash, Editor module initialization order, assumptions made by
legacy no-current-engine tests, stale function-library stack coordinates,
obsolete suite prefixes, a local StaticJIT AOT cache, and one Debugger group
timeout that did not reproduce in three focused reruns.

The relevant boundaries are important:

- `AngelscriptRuntime` owns production engine resolution and Debugger transport.
- `AngelscriptEditor` owns Project Settings registration.
- `AngelscriptTest` owns AOT fixture generation and all test-only environment
  controls.
- The root test suite definition owns the automation group-to-prefix mapping.
- The StaticJIT cache is already ignored by Git, but the existing tests expect
  it beneath the source tree and therefore inherit stale local state.

## Goals / Non-Goals

**Goals:**

- Restore deterministic, meaningful automation coverage for each identified
  failure without weakening assertions merely to make the suite green.
- Make the StaticJIT AOT cache an entirely test-owned, rebuildable `Saved/`
  artifact while continuing to verify committed generated C++ source.
- Keep production subsystem fallback behavior intact while allowing tests to
  deliberately exercise no-current-engine branches.
- Make the Debugger transport safe for normal TCP fragmentation, independently
  of whether it is the only cause of the observed timeout.
- Ensure the `All` suite's group labels match current test registration IDs.

**Non-Goals:**

- Change the consumer-facing StaticJIT precompiled-data format, cache location,
  or production loading policy.
- Regenerate and commit a binary StaticJIT fixture cache.
- Change UHT function binding behavior or include unrelated Wiki work.
- Attribute the one Debugger timeout to a single cause without reproducible
  evidence.

## Decisions

### 1. StaticJIT AOT cache is provisioned only by the test fixture

`AngelscriptTest/StaticJIT/AOT` will expose a test-only helper that ensures a
cache for the current fixture GUID and current build identifier exists below
`FPaths::ProjectSavedDir()/StaticJIT/AOT`. Missing, malformed, wrong-GUID, or
wrong-build caches are regenerated from the in-memory AOT fixture before a
runtime AOT test loads precompiled data. Generation writes through a temporary
file and atomically publishes the resulting cache; a process-local lock avoids
competing fixture generations.

The checked-in `.jit.cpp` and `.jit.hpp` files remain under the test module
source tree. `Verify` mode continues comparing fresh generated text with those
files. The runtime fixture path will never write source artifacts, so ordinary
automation runs cannot dirty the source tree.

Alternatives rejected:

- **Manually regenerate a cache:** immediately unblocks one workspace but
  recreates the failure after a schema/configuration change.
- **Commit the cache:** contradicts its ignored/local role and adds a
  build-dependent binary artifact to review history.
- **Run a commandlet and full rebuild before every suite:** changes source files
  during testing and makes the normal full suite unnecessarily slow.

### 2. No-current-engine tests use an explicit test-only resolver suppression

The production resolver intentionally selects a scoped engine first and then
the primary `UAngelscriptSubsystem` engine. Emptying the context stack does not
mean there is no current engine in an editor process anymore.

A scoped, `WITH_DEV_AUTOMATION_TESTS`-only suppression will be added adjacent
to engine-context test access. While active on the test thread, it makes
`TryGetCurrentEngine()` and `IsInitialized()` report no resolved engine; scope
exit restores normal resolution. Tests whose purpose is legacy/no-engine branch
coverage will use it instead of destroying or detaching the production
subsystem. Normal engine scopes and all shipping behavior remain unchanged.

Alternatives rejected:

- **Relax no-engine assertions:** loses coverage of an intentional fallback
  branch.
- **Temporarily shut down the Editor subsystem:** mutates global editor state
  and risks cross-test damage.

### 3. Settings registration eagerly acquires its declared dependency

`AngelscriptEditor.Build.cs` already declares `Settings` as a private
dependency. `StartupModule()` will use `LoadModuleChecked<ISettingsModule>`
before registering the two Project Settings sections. `ShutdownModule()` keeps
the non-loading `GetModulePtr` form so module shutdown does not start Settings.

This converts a timing-dependent optional registration into the existing
required editor feature. The compile-options validator remains attached to the
registered section.

### 4. Builder cleanup maintains both global-description containers

The AngelScript fork removes enum value descriptions from its symbol table and
deletes them after compilation, but leaves their raw pointers in
`globVariableList`. The cleanup will remove each enum description from every
owning/diagnostic container before deletion. A focused SDK regression will
exercise the post-build description path that previously read a dangling
pointer.

Avoiding only the diagnostics traversal is rejected because it would hide a
real stale-pointer ownership defect in the fork.

### 5. Test metadata reflects present behavior without masking it

The Widget and World tests will assert the source coordinates emitted by their
current `ASTEST_AS` fixtures. The `All` suite will replace both obsolete
`ClassGenerator` and `ScriptClass` entries with a single `Generator` prefix
that covers the actual `Angelscript.TestModule.Generator.*` registrations once.

### 6. Debugger transport treats TCP as a byte stream

Per-client receive buffers will accumulate available socket bytes. The server
will parse only complete `[int32 length][payload]` envelopes and retain partial
headers/payloads for a later tick. Invalid envelope lengths will discard the
client with a deterministic protocol error rather than entering a partial-read
loop. Disconnect/reset paths will also remove the associated receive buffer.

The parser will be factored so Debugger-layer tests can feed split envelope
fragments without relying on timing of a real TCP peer. Focused Debugger prefix
stress reruns remain a complementary end-to-end check.

## Risks / Trade-offs

- **Generating a cache during a test has a small first-use cost** → Reuse a
  validated `Saved/` cache for the current build and serialize generation with
  a process-local lock.
- **Generated C++ could be stale while a freshly generated cache is valid** →
  Preserve the independent generated-source verification test; runtime tests
  continue proving that compiled generated code registers and executes.
- **Test resolver suppression could escape its intended boundary** → Compile it
  only for development automation, make it RAII-only, restrict it to the test
  thread, and add restoration assertions.
- **A Debugger transport refactor can change malformed-packet behavior** → Keep
  the binary envelope format and maximum-size contract; add explicit valid
  fragmented and invalid-length tests.
- **Unrelated dirty worktrees can conceal ownership** → Stage/commit only files
  named by this change; preserve the pre-existing root, plugin, and Wiki edits.

## Migration Plan

1. Add focused red tests or retain the already failing focused tests for every
   deterministic defect.
2. Implement fixture/cache, engine-resolution, builder, Settings, suite-prefix,
   expected-coordinate, and Debugger framing changes in their owning modules.
3. Delete the obsolete ignored source-tree fixture cache if it is present; no
   repository deletion is expected because it is not tracked.
4. Run focused tests, a project build, Debugger stress reruns, and the `All`
   suite through the approved `Tools/` entry points.
5. Record actual command results in `verification.md`, commit the plugin
   submodule first, then commit the parent OpenSpec/tooling gitlink update.

Rollback is straightforward: code and source artifacts can revert while any
`Saved/` cache is discarded as derived data. No user data or versioned binary
cache requires migration.

## Open Questions

- The exact source of the earlier Debugger timeout remains unproven. The
  fragmented-envelope change is justified by the existing partial-read defect;
  implementation must not claim a stronger root cause than the evidence.
- The focused test will determine whether the test-only no-engine suppression
  belongs on `FAngelscriptEngineContextStack` or the test access shim, provided
  its production visibility remains unchanged.
