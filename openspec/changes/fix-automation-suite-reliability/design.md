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
- The StaticJIT cache is already ignored by Git, and it forms a required pair
  with pointer-style reference IDs embedded in generated C++ compiled into the
  test DLL.

## Goals / Non-Goals

**Goals:**

- Restore deterministic, meaningful automation coverage for each identified
  failure without weakening assertions merely to make the suite green.
- Give StaticJIT AOT coverage one explicit preflight command that regenerates
  the cache and generated C++ together, rebuilds the module, then runs tests.
- Keep production subsystem fallback behavior intact while allowing tests to
  deliberately exercise no-current-engine branches.
- Make the Debugger transport safe for normal TCP fragmentation, independently
  of whether it is the only cause of the observed timeout.
- Ensure the `All` suite's group labels match current test registration IDs.

**Non-Goals:**

- Change the consumer-facing StaticJIT precompiled-data format or production
  loading policy.
- Regenerate and commit a binary StaticJIT fixture cache.
- Change UHT function binding behavior or include unrelated Wiki work.
- Attribute the one Debugger timeout to a single cause without reproducible
  evidence.

## Decisions

### 1. StaticJIT AOT artifacts are prepared as one generated-and-compiled pair

The AOT cache serializes reference IDs that are emitted as `FJitRef_*`
constructor arguments in `.jit.cpp` / `.jit.hpp`. These IDs are process-local
pointers, so a cache generated at runtime cannot be loaded by a DLL compiled
from an older generated source pair. The failed experiment reaches
`PrecompiledData.cpp`'s `RefPtr != nullptr` assertion, proving that cache-only
refresh is unsafe.

`Tools/RunStaticJITTests.ps1` will be the dedicated test-only entry point. It
will run: (1) baseline build, (2) the `Generate` commandlet to write the
ignored cache and checked-in generated C++ as one pair, (3) a second build to
compile that C++, and (4) the StaticJIT automation prefix. Any failed phase
stops the workflow. The fixture error guidance and testing guide point to this
entry point; tests themselves never rewrite artifacts.

The checked-in `.jit.cpp` and `.jit.hpp` files remain under the test module
source tree. `Verify` mode continues comparing fresh generated text with those
files. The matching cache remains ignored in that generated-artifact directory
and is never committed.

Alternatives rejected:

- **Regenerate only a cache in the test process:** unsafe because it has
  reference IDs that do not match the currently compiled generated C++.
- **Commit the cache:** contradicts its ignored/local role and adds a
  build-dependent binary artifact to review history.
- **Redesign StaticJIT reference serialization:** could remove the pairing
  constraint, but it is a broad product-format change outside this
  automation-reliability repair.

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

- **Preparation rewrites generated source before the test run** → Confine it
  to an explicit StaticJIT-only tool and keep generated-source verification in
  the final prefix. Ordinary runtime tests never write artifacts.
- **Generated C++ could be stale while a cache exists** → The tool always
  regenerates both artifacts and rebuilds before runtime tests execute.
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
3. Delete any obsolete ignored fixture cache before preparation; the commandlet
   recreates the paired local artifact and no repository deletion is expected.
4. Run focused tests, a project build, Debugger stress reruns, and the `All`
   suite through the approved `Tools/` entry points.
5. Record actual command results in `verification.md`, commit the plugin
   submodule first, then commit the parent OpenSpec/tooling gitlink update.

Rollback is straightforward: code and generated source artifacts can revert
while the ignored local cache is discarded as derived data. No user data or
versioned binary cache requires migration.

## Open Questions

- The exact source of the earlier Debugger timeout remains unproven. The
  fragmented-envelope change is justified by the existing partial-read defect;
  implementation must not claim a stronger root cause than the evidence.
- The focused test will determine whether the test-only no-engine suppression
  belongs on `FAngelscriptEngineContextStack` or the test access shim, provided
  its production visibility remains unchanged.
