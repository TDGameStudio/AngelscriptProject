# Plugin Change Necessity Review — 2026-08-01

> **Architecture correction (2026-08-01):** Shared `AngelscriptLanguageCore`, Runtime `Language/`, and UE frontend-migration statements in this record are preserved as historical evidence and are no longer the active design. UE keeps its original authoritative preprocessor/descriptor path; Standalone owns `Standalone/Source/Compiler/Frontend` privately, and the hosts exchange only the complete offline JSON bundle.


## Record status

- Change: `feature-ue-angelscript-standalone-compiler`
- Review purpose: determine which current `Plugins/Angelscript` workspace
  changes are required by Standalone V1, which are valid but broader than the
  approved boundary, and which are unrelated residue.
- Decision state: **selected on 2026-08-01**. Accepted and partially accepted
  items are promoted into `tasks.md`; rejected items retain their verified
  technical rationale here so later cleanup does not reopen them accidentally.
- Implementation state: selection is recorded, but no selected item is complete
  until its focused RED/GREEN evidence and final verification are attached.
- Review basis: static source/diff review plus inspection of generated CMake
  project properties. Existing Debug/Release and UE verification records remain
  evidence of behavior, but they do not cover every boundary issue below.

## Reviewed workspace snapshot

At the time of review, the plugin submodule contained:

- 28 tracked files with substantive diffs;
- approximately 1,437 tracked insertions and 307 tracked deletions;
- 242 untracked files:
  - 200 beneath `Standalone/`;
  - 13 beneath `Source/AngelscriptRuntime/Language/`;
  - 18 Runtime offline export files;
  - 6 Editor offline export/Commandlet files;
  - 5 offline contract test files.

The tracked Coverage/Input, Coverage/UStruct, and shared test-macro changes
account for approximately 796 inserted lines. They are more than half of the
tracked insertions but are not required by the Standalone architecture.

## Boundaries confirmed by the review

The following approved boundaries are still represented correctly and should
not be reopened merely because the candidate findings below exist:

- `.uplugin` contains no new Standalone module, setting, or public compile
  option.
- `WITH_ANGELSCRIPT_STANDALONE` and `AS_STANDALONE` do not appear in the
  maintained fork, bindings, or ClassGenerator.
- Existing `Bind_*.cpp` and ClassGenerator sources are not compiled into the
  Standalone target and contain no exporter call or symbol-only Standalone
  branch.
- Binding provenance records the existing Manual, Generated, NativeModule, and
  Reflective registration paths centrally; it does not create a second binding
  implementation.
- UE exports one complete final JSON contract and Standalone consumes it. The
  project does not maintain a second hand-authored Standalone registration
  surface.
- The large standard-library portability rewrite has been removed from the
  maintained fork. UE-spelled containers, memory, atomics, math, settings, and
  host facades remain authoritative and are substituted through
  `Standalone/Compat` for the CMake build.
- The retained fork edits are predominantly host-neutral semantic observation,
  add-on parser compatibility, bytecode restore symmetry, generic-call
  correctness, and repeatable engine teardown.

## Candidate summary

| ID | Candidate | Review priority | Current decision |
|---|---|---:|---|
| PR-01 | Make maintained-fork CMake definitions private | High | Accepted |
| PR-02 | Stop `Standalone/Compat` include propagation | High | Accepted |
| PR-03 | Close zero-size counted-allocation lifetime gap | High | Accepted |
| PR-04 | Narrow UE Runtime debugging definitions to private | Medium | Rejected |
| PR-05 | Align external-project documentation with evidence | Medium | Accepted |
| PR-06 | Split unrelated Coverage/test changes | Medium | Accepted as commit-scope isolation |
| PR-07 | Make Editor `AssetRegistry` dependency private | Low | Rejected |
| PR-08 | Remove or implement `ValidateBundleKind` | Low | Accepted: remove no-op API |
| PR-09 | Remove optional/residual fork and dump cleanup | Low | Partially accepted |
| PR-10 | Strengthen CMake interface architecture gates | Medium | Accepted |

Priority expresses review risk, not approval. A selected candidate must receive
its own task entry and verification evidence before it can be marked complete.

## PR-01 — Make maintained-fork CMake definitions private

### Observation

`Standalone/CMakeLists.txt` currently declares the maintained-fork definition
set as `PUBLIC`, including:

- `AS_MAX_PORTABILITY`;
- `AS_NO_THREADS`;
- `AS_USE_EXCEPTIONS=1`;
- `AS_REFERENCE_DEBUGGING=0`;
- `WITH_AS_DEBUGSERVER=0`;
- `ANGELSCRIPT_EXPORT`;
- `ANGELSCRIPTRUNTIME_API=`;
- `DO_BLUEPRINT_GUARD=0`;
- `UE_BUILD_SHIPPING=0`;
- `WITH_EDITOR=0`.

Generated `AngelscriptStandaloneAddons`, `AngelscriptStandaloneHost`, CLI, and
test projects therefore inherit the complete definition set. In particular,
`AS_USE_EXCEPTIONS=1` propagates beyond `AngelscriptMaintainedFork`, contrary to
the private, non-propagated policy in `design.md` and the completed task in
section 2B. `ANGELSCRIPT_EXPORT` also reaches static-library consumers even
though `angelscript.h` documents that static-link consumers should define no
DLL export/import macro.

### Necessity judgment

- The definitions are generally necessary while compiling the maintained fork.
- Their `PUBLIC` visibility is not established as necessary and expands the
  Standalone Host/add-on compile contract beyond the approved boundary.

### Selection options

1. Recommended: make the complete maintained-fork policy set `PRIVATE`, then
   add an explicit definition only to a downstream target that proves it needs
   one.
2. Split the block into a private fork policy and a separately justified,
   minimal interface block.
3. Retain the current propagation only if generated-project evidence and a
   documented ABI/header requirement prove each public definition is required.

### Verification if selected

- Reconfigure the Win64 preset from current CMake source.
- Inspect `INTERFACE_COMPILE_DEFINITIONS` or generated Host/Addons/CLI project
  files and prove fork-private definitions are absent.
- Rebuild and run the complete Debug and Release Standalone test matrices.
- Preserve UBT `AS_NO_EXCEPTIONS` behavior.

## PR-02 — Stop `Standalone/Compat` include propagation

### Observation

`Standalone/Compat` is currently added to `AngelscriptMaintainedFork` as
`BEFORE PUBLIC`. Because the maintained-fork target is linked transitively, the
Compat include tree appears in generated Addons, Host, CLI, and test projects.

This conflicts with the design statement that Compat is selected only for the
CMake maintained-fork target and must not become an ordinary Standalone Host
dependency.

### Necessity judgment

- Placing Compat before Runtime/fork includes for maintained-fork compilation
  is necessary.
- Propagating that include directory to ordinary consumers is not necessary for
  the current Host source, which consumes `angelscript.h` and explicit
  Standalone interfaces rather than the UE facade.

### Selection options

1. Recommended: use `BEFORE PRIVATE` for the maintained-fork Compat directory.
2. Add Compat explicitly and privately only to the focused compatibility test
   target that intentionally includes its facade headers.
3. Retain public propagation only if every receiving target is intentionally
   classified as a Compat consumer and that broader architecture is recorded.

### Verification if selected

- Prove `Standalone/Compat` is present in the maintained-fork generated project.
- Prove it is absent from Addons, Host, CLI, and ordinary test projects except
  for explicitly declared compatibility tests.
- Run architecture, compatibility, Debug, and Release Standalone tests.

## PR-03 — Close zero-size counted-allocation lifetime gap

### Observation

`FCountingAllocator::Allocate(0, Alignment)` can allocate a real header-backed
address, store `Header->Owner = State`, and leave `CurrentBytes == 0`. The
allocator destructor deletes `State` whenever `CurrentBytes == 0`. A zero-size
address released after allocator destruction can therefore dereference a stale
owner pointer in `Free`.

The existing outstanding-allocation fallback intentionally preserves State for
non-zero leaked bytes, so zero-size allocations are an uncovered exception to
the intended lifetime rule. Existing runtime tests cover non-zero allocation
limits but do not exercise zero-size ownership.

### Necessity judgment

- The hard-limit allocator is required by the native runtime contract.
- Zero-size requests may be uncommon, but the current lifetime inference is not
  complete. This is a correctness candidate rather than optional cleanup.

### Selection options

1. Recommended: track outstanding allocation count independently from byte
   count and retain State while either value is non-zero.
2. Normalize every allocation to at least one charged byte, documenting the
   hard-limit accounting change.
3. Explicitly reject zero-size allocation if AngelScript/add-on allocation
   contracts permit it and focused tests prove that policy safe.

### Verification if selected

- Add focused zero-size allocation/free tests.
- Cover freeing a zero-size allocation after allocator destruction.
- Preserve current/peak/rejection accounting for existing non-zero tests.
- Re-run native runtime, lifecycle, soak, Debug, and Release tests.

## PR-04 — Narrow UE Runtime debugging definitions to private

### Observation

`AngelscriptRuntime.Build.cs` now defines `AS_REFERENCE_DEBUGGING` and
`WITH_AS_DEBUGSERVER` through `PublicDefinitions`.

Providing stable values at Build.cs level is justified: separately compiled
fork translation units do not all include `AngelscriptEngine.h`, and non-Unity
builds must not depend on accidental PCH/unity macro state. However, these are
Runtime implementation policies. Public visibility propagates them to every
dependent plugin module.

`AngelscriptEngine.h` already has guarded fallback definitions for consumers.

### Necessity judgment

- Explicit Runtime-module definitions are necessary for consistent fork
  translation units.
- Public propagation is not clearly necessary and should be treated as a new
  public plugin macro surface unless narrowed.

### Selection options

1. Recommended: change both definitions to `PrivateDefinitions`.
2. If a test module directly consumes fork-private layout-bearing headers, give
   that test module an explicit matching definition rather than widening the
   Runtime interface.
3. Retain `PublicDefinitions` only with evidence that public Runtime headers
   expose a cross-module conditional layout that cannot use the guarded
   fallback safely.

### Verification if selected

- Run a UE Development build through `Tools/RunBuild.ps1`.
- Run active NativeCore, Compiler, Bindings, and Editor OfflineContract tests.
- Include a non-Unity build configuration if available in the standard wrapper.

## PR-05 — Align external-project documentation with evidence

### Observation

The plugin README states that external projects run the same plugin-owned
Commandlet and export their own project bundle. The implementation is
plugin-owned and contains no identified dependency on the minimal
`AngelscriptProject` host module, which is the intended architecture.

However, tasks 49 and 92 remain incomplete because a real external consuming
`.uproject` has not yet provided the complete Commandlet-to-installed-CLI smoke
evidence. Chinese-first documentation and final verification updates also
remain incomplete.

### Necessity judgment

- The reusable plugin-owned Commandlet is required.
- Published external-project wording should not be treated as a completed claim
  before the external project smoke exists.

### Selection options

1. Recommended: finish the external-project Commandlet export and explicit
   project-bundle compile smoke, then keep the current claim.
2. Temporarily qualify the README wording until evidence is recorded.
3. Defer external-project support and narrow V1 claims, which would require
   revising the existing offline-contract requirement and product goal.

### Verification if selected

- Use a consuming project outside the repository host module.
- Enable the plugin and invoke the normal Unreal Commandlet entry directly.
- Export `BundleKind=Project` twice and prove deterministic publication.
- Consume the exported directory with the installed CLI using explicit
  `--bundle`, with no merge or fallback.
- Update Chinese guidance first, then English documentation and final evidence.

## PR-06 — Split unrelated Coverage/test changes

### Observation

The plugin dirty workspace includes substantial changes in:

- `Source/AngelscriptTest/Coverage/AngelscriptCoverageInputTests.cpp`;
- `Source/AngelscriptTest/Coverage/AngelscriptCoverageUStructTests.cpp`;
- `Source/AngelscriptTest/Shared/AngelscriptTestMacros.h`.

These changes add Coverage cases and line-preserving test-fixture helpers. They
do not implement the Standalone build, LanguageCore, offline JSON contract,
export Commandlet, bundle consumer, or retained fork behavior.

The Native Engine smoke adjustment from `double` to `uint` is a defensible
correction of an invalid distinct-type assumption and may accompany the public
AngelScript compatibility aliases or be separated as test cleanup. The
CopyScript restore round-trip test is directly tied to the retained restore
fix and should remain with that behavior.

### Necessity judgment

- Coverage and shared macro additions may be valid project work.
- They are not necessary to this OpenSpec and must not be included merely
  because they share the plugin submodule workspace.

### Selection options

1. Recommended: preserve the changes but commit them under their owning
   Coverage/test change before or separately from Standalone.
2. Leave them uncommitted while preparing a path-scoped Standalone commit.
3. Include them here only after intentionally expanding this OpenSpec, which is
   not currently justified.

### Verification if selected

- Inspect the exact submodule commit diff before updating the parent gitlink.
- Confirm the Standalone commit contains no unrelated Coverage/TestMacros hunk.
- Verify separated Coverage work through its own test scope.

## PR-07 — Make Editor `AssetRegistry` dependency private

### Observation

`AngelscriptEditor.Build.cs` adds `AssetRegistry` to
`PublicDependencyModuleNames`. The public offline asset exporter header only
forward-declares `IAssetRegistry`; the concrete Asset Registry includes and
operations live in Editor `.cpp` files.

### Necessity judgment

- The Editor implementation requires `AssetRegistry`.
- A public module dependency is not established as necessary by the current
  exported header surface.

### Selection options

1. Recommended: move `AssetRegistry` to `PrivateDependencyModuleNames`.
2. Retain it as public only if a public inline/template/header dependency is
   introduced and documented.

### Verification if selected

- Run the UE Development build.
- Run Editor OfflineContract/Commandlet tests.
- Verify an external module can include the public exporter header without
  inheriting an unnecessary AssetRegistry dependency.

## PR-08 — Remove or implement `ValidateBundleKind`

### Observation

`FAngelscriptOfflineExportService::ValidateBundleKind` currently discards all
arguments, clears the error, and returns true. This reflects the revised design
that `DefaultEngine` and `Project` are selection/distribution roles rather than
symbol-content filters, but its name and call sites imply real validation.

### Necessity judgment

- Content filtering by bundle kind must not return.
- A permanently successful function named `ValidateBundleKind` is not needed
  and may conceal invalid enum or scope states.

### Selection options

1. Remove the function and express the no-filter rule directly at the build and
   Commandlet boundary.
2. Retain the function but validate only legal enum/scope invariants, never
   producer-origin content filters.
3. Keep the no-op temporarily, with an explicit comment/test stating it is a
   compatibility seam scheduled for removal.

### Verification if selected

- Run Runtime and Editor OfflineContract tests.
- Add invalid-enum/scope coverage if validation remains.
- Preserve identical full symbol traversal for `DefaultEngine` and `Project`.

## PR-09 — Remove optional/residual fork and dump cleanup

### Observation

Two `AngelscriptStateSnapshot.cpp` loops changed from explicit `TPair` types to
`const auto&`. Standalone does not compile StateSnapshot, and the final
Compat-first design no longer changes the UE Runtime container types. These
edits are residue from the superseded standard-library portability pass.

`as_scriptobject.cpp` also deletes unused generic wrapper functions. Only the
two added `asFunctionCaller{}` arguments are functionally required by the
maximum-portability registration path. Removing dead wrappers can reduce C4505
warnings, but it is cleanup rather than required Standalone behavior.

### Necessity judgment

- Revert the two StateSnapshot edits for a minimal scoped diff.
- Choose whether dead-wrapper removal is kept as a separate warning cleanup or
  restored to minimize the maintained-fork delta.
- Preserve the two required `asFunctionCaller{}` call-site fixes.

### Selection options

1. Recommended minimum-diff choice: restore StateSnapshot and the unused
   wrappers; retain only functional call-site changes.
2. Restore StateSnapshot but keep wrapper deletion in a separate documented
   cleanup commit.
3. Keep all cleanup here only if the OpenSpec explicitly accepts warning-only
   fork cleanup as part of the delivery.

### Verification if selected

- Inspect the maintained-fork diff against the semantic allowlist in design
  decision 1.
- Rebuild Standalone Debug/Release and run NativeCore regression tests.

## PR-10 — Strengthen CMake interface architecture gates

### Observation

The current architecture test checks that CMake text names
`ANGELSCRIPT_STANDALONE_COMPAT` and that prohibited source/path patterns are
absent. It does not inspect effective target interface properties or generated
consumer projects. Consequently, PR-01 and PR-02 can coexist with passing
architecture and complete `18/18` CTest results.

### Necessity judgment

- Existing source/path scans remain necessary.
- Effective propagation checks are needed if the private build boundary is to
  be a verified product requirement rather than a source-text convention.

### Selection options

1. Recommended: query CMake `INTERFACE_COMPILE_DEFINITIONS` and
   `INTERFACE_INCLUDE_DIRECTORIES` through a configure-time assertion or a
   focused inspection target.
2. Inspect generated Addons/Host/CLI project files in the architecture test.
3. Maintain both: property checks for the contract and generated-project checks
   as MSVC release evidence.

### Verification if selected

- First demonstrate the gate fails with current public definitions/includes.
- Apply selected PR-01/PR-02 changes and demonstrate the gate passes.
- Run the full Debug and Release Standalone matrices.

## Current necessity classification by implementation area

| Area | Current review classification |
|---|---|
| `Standalone/` CLI, Host, Compat, contract consumer, tests, packaging | Required by Standalone V1 |
| `Source/AngelscriptRuntime/Language/` | Required by the approved shared LanguageCore architecture |
| UE preprocessor delegation of module identity and range-for rewrite | Required shared-algorithm migration; broader facade parity remains deferred |
| Runtime offline exporters and Editor Commandlet | Required to avoid a second registration implementation |
| Offline contract tests | Required for deterministic/address-free JSON evidence |
| Binding provenance and UHT generated-origin path | Required export bridge; later manual-binding architecture should absorb it |
| `angelscript.h` add-on compatibility aliases and typed user data | Required by imported add-ons/semantic observer |
| Compiler semantic observer | Required at resolved semantic sites; cannot be reconstructed reliably by Host text parsing |
| Parser named `&in`/`&out` compatibility | Required by pinned official add-on declarations |
| Restore symmetry and regression test | Required by bytecode round-trip and repeated-engine behavior |
| Script engine/context lifecycle fixes | Required where focused lifecycle/UE regression evidence exists |
| `as_scriptobject.cpp` `asFunctionCaller{}` call-site fixes | Required |
| `as_scriptobject.cpp` unused-wrapper deletion | Optional cleanup |
| StateSnapshot `const auto&` edits | Unrelated residue |
| Coverage Input/UStruct and shared test-macro additions | Unrelated to this OpenSpec |
| UE 5.8 generated default bundle/archive | Required release input explicitly selected for V1 |

## Selection log

Selection does not mark an item complete. Completion requires the promoted
`tasks.md` entry and its focused/final evidence.

| ID | Decision | Date | Promoted task/evidence | Notes |
|---|---|---|---|---|
| PR-01 | Accept | 2026-08-01 | `tasks.md` section 2C | Keep the complete maintained-fork policy private. |
| PR-02 | Accept | 2026-08-01 | `tasks.md` section 2C | Keep Compat private to the maintained-fork target. |
| PR-03 | Accept | 2026-08-01 | `tasks.md` section 2C | Track allocation ownership independently from byte count. |
| PR-04 | Reject | 2026-08-01 | This record | `AngelscriptTest` consumes layout-bearing internal SDK headers across the Runtime module boundary; private definitions would risk layout mismatch or duplicate policy declarations. |
| PR-05 | Accept | 2026-08-01 | `tasks.md` sections 2C and 8 | Require a real external content-only project and installed-package consumer evidence. |
| PR-06 | Accept | 2026-08-01 | `tasks.md` section 2C | Preserve Coverage/Input, Coverage/UStruct, and shared TestMacros as unrelated workspace changes; exclude them by path. |
| PR-07 | Reject | 2026-08-01 | This record | Existing public Editor headers already include AssetRegistry types, so the dependency has a broader established public-header basis. |
| PR-08 | Accept | 2026-08-01 | `tasks.md` section 2C | Remove the misleading always-successful API, its calls, and obsolete direct tests. |
| PR-09 | Partial accept, revised by build evidence | 2026-08-01 | `tasks.md` section 2C | Restore the two StateSnapshot loops, retain the required `asFunctionCaller{}` fixes, and keep the eight wrappers deleted because a fresh Release compile proves their methods do not exist with `AS_REFERENCE_DEBUGGING=0`. |
| PR-10 | Accept | 2026-08-01 | `tasks.md` section 2C | Add a configure-time effective target-interface gate. |

## Verification status of this record

- This is a review record, not implementation evidence.
- No plugin code, Build.cs, CMake, test, documentation, or package artifact was
  changed while creating it.
- Existing passing suites prove current behavior but do not close the review
  candidates until the relevant missing boundary/lifetime/external-project
  checks are selected and executed.
