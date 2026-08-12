# Plan-Only Verification — 2026-08-12

## Delivered Scope

This round changed only `openspec/changes/refactor-as-static-jit-multi-provider/` and its current OpenSpec cross-references. It did not modify:

- `Plugins/Angelscript` or any vendored AngelScript source;
- host `Source/` or `AngelscriptProject.uproject`;
- `.uplugin`, Build.cs, generated JIT C++, Cache V2 data, commandlets, tools, or tests;
- build products, Saved cache data, or Editor state.

The OpenSpec was refactored from the earlier external-provider plan into a ready-to-execute plan covering:

- one breaking, non-versioned, lifecycle-aware AS JIT Binding interface;
- adoption of the useful AS 2.38 delayed-publication/cleanup semantics without retaining v1/v2 APIs;
- neutral Cache V2/StaticJIT artifact routes and stable references;
- current-revision provider ABI and engine-local reference slots;
- process-wide multi-provider Registry supporting several UE Provider modules, multi-AS-module Providers, owner-scoped unload, per-Provider generations, and deterministic cross-Provider ambiguity fallback;
- Editor/PIE current-function routing and reflected `UASFunction` VM/Raw/Parms dispatch;
- Editor-only `AngelscriptTestJIT` generated-code carrier isolated from all project inputs, naming, Scaffold, descriptors, settings, outputs, and lifecycle;
- fixed project module `AngelscriptJIT` at `Source/AngelscriptJIT`;
- `AngelscriptEditor`-owned project `-run=AngelscriptJIT -Mode=Scaffold|Generate|Verify`;
- `AngelscriptTest`-owned plugin-fixture `-run=AngelscriptTestJIT -Mode=Generate|Verify`;
- content-addressed function slices and exactly 32 fixed bucket translation units;
- explicit Editor Live Coding refresh after one normal full build;
- source-engine plus Cache V2 fresh-engine AOT tests;
- Development/Shipping behavior, diagnostics, Python dump inspection, performance, packaging, and full-suite gates.

## Artifact Inventory

Normative/working artifacts now include:

- `proposal.md`
- `design.md`
- `tasks.md` with 63 unchecked future implementation tasks
- `implementation-plan.md`
- `verification.md`
- historical progressive `research.md`, retained and marked with a 2026-08-12 supersession section
- new focused `jit-interface-238-test-module-research.md`
- seven capability delta specs:
  - `as-jit-lifecycle-interface`
  - `as-static-jit-artifact-provider`
  - `as-static-jit-editor-routing`
  - `as-static-jit-module-scaffolding`
  - `as-static-jit-aot-test`
  - `static-jit-diagnostics`
  - `uasfunction-dispatch-matrix-and-jit-paths`

All task boxes remain unchecked because this was an OpenSpec-only refactor. The previous 31-item checklist was replaced rather than marked complete.

## Consistency Checks

- Modified capability requirement names match their existing base-spec requirements exactly.
- All delta scenarios use OpenSpec `#### Scenario` structure.
- Normative module naming is consistently `AngelscriptTestJIT` for plugin tests and fixed `AngelscriptJIT` for projects; ProviderId remains project/source-domain-specific.
- Old names/API terms occur in normative artifacts only where the plan explicitly describes current source evidence, rejected alternatives, or required removal.
- `AngelscriptTestJIT` is consistently Editor-only and contains generated code/probes only; it is not a project scaffold or project source target.
- `AngelscriptTest` owns only plugin-fixture tests and the isolated `AngelscriptTestJIT` Generate/Verify entry; `AngelscriptEditor` owns project `AngelscriptJIT` Scaffold/Generate/Verify.
- Several UE Provider modules may coexist in one Registry, one Provider may contain several AS modules, and each AS Engine owns independent resolved state.
- Same-Provider generations replace safely; different-Provider exact conflicts produce `AmbiguousExactProvider` and VM rather than load-order override.
- Runtime depends on neither TestJIT nor project JIT provider modules.
- Cache V2 and StaticJIT share neutral identity/route/reference values but retain separate cache-store and JIT-provider responsibilities.
- The implementation order starts with AS lifecycle ownership, then neutral artifacts/provider/routing, and only then creates modules and Live Coding integration.

## Multi-Module Follow-Up Evidence

The 2026-08-12 follow-up inspected current source before changing the record:

- `FStaticJITFunction` construction appends VM/Raw/Parms entries to `FJITDatabase::Get().Functions` by numeric FunctionId;
- generated reference constructors append to global reference arrays in the same database;
- static constructors from multiple translation units or loaded modules can therefore reach one accumulator;
- `FStaticJITCompiledInfo` still enforces one active precompiled-data identity;
- FunctionId overwrite, all-database clear, absent Provider ownership, and absent owner-scoped unload mean this is not true multi-provider support.

The revised OpenSpec consequently requires a new owner-aware Registry rather than describing the current database as already multi-module. It separately covers multiple UE Provider modules, multiple AS modules per Provider, and multiple Engine-local consumers.

## Validation Evidence

The following commands were run after the 2026-08-12 proposal, design, specs, tasks, implementation plan, and research attachment were present:

```powershell
openspec status --change refactor-as-static-jit-multi-provider --json
openspec validate refactor-as-static-jit-multi-provider --strict
```

Observed result:

- both commands returned exit code `0`;
- status reported `schemaName: spec-driven` and `isComplete: true`;
- proposal, design, specs, and tasks all reported `done`;
- strict validation reported `Change 'refactor-as-static-jit-multi-provider' is valid`.

The final verification pass after this file was written reran strict validation and `git diff --check`; both returned exit code `0`. `git status --short` showed only the renamed StaticJIT change, its current OpenSpec cross-references, and the shared artifact-identity spec. No plugin or host-project source path was modified. The line-ending notices are Git's existing LF-to-CRLF checkout warning and are not `diff --check` failures.

## Change Rename Verification

On 2026-08-12 the active change directory was renamed from
`refactor-as-static-jit-external-module` to
`refactor-as-static-jit-multi-provider`. The rename intentionally describes
the architectural outcome—stable multi-Provider registration, routing,
generation replacement, and module-backed artifacts—rather than only one
external UE module.

The rename pass verified:

- `openspec list --json` discovers only the new active change name;
- `openspec status --change refactor-as-static-jit-multi-provider --json`
  reports all required artifacts present and 63 implementation tasks;
- strict validation passes for `refactor-as-static-jit-multi-provider`,
  `refactor-as-incremental-function-cache`, and
  `feature-as-typed-semantic-aot`;
- the only active occurrences of the old name are the explicit rename
  mappings in `research.md` and this verification record;
- archived snapshots retain the old name and were not rewritten;
- `git diff --check` returns exit code `0`.

`openspec validate --all --strict` reported 142 passing items and two existing
unrelated empty-delta failures:
`docs-as-mutable-global-feasibility` and
`refactor-as-runtime-assets-and-singletons`. Neither path is part of this
rename diff. Targeted strict validation of every change touched by the rename
passes, so these repository-wide baseline failures are recorded but not
modified as part of this OpenSpec-only rename.

No C++ build, Unreal Automation run, Editor launch, PIE session, Live Coding patch, or package run is claimed because the user explicitly restricted this round to OpenSpec changes.

## Historical Verification Retained

The 2026-08-08 plan-only packet had six capability deltas and 31 unchecked tasks and correctly recorded that no source implementation had occurred. Its research history remains in `research.md` and Git history. This 2026-08-12 packet supersedes its module suffix, JIT-interface boundary, route ownership, TestJIT topology, commandlet ownership, single-global-database assumptions, test-cache strategy, and implementation order; it does not retroactively describe those earlier choices as implemented.

## Implementation Handoff

Implementation should begin at `tasks.md` group 1 with native AngelScript JIT lifecycle tests. It should not begin by scaffolding the provider modules. Before group 2, re-confirm the current Cache V2 artifact identity/route types and focused regression baseline; then neutralize reusable types without moving cache persistence policy into StaticJIT.

The first source-level completion claim is valid only after the unified Binding publish/release tests pass. The feature-level completion claim is valid only after `AngelscriptTestJIT`, host project JIT module, Editor/PIE, Live Coding, Development/Shipping package, multi-start, diagnostics, focused prefixes, and configured All-suite evidence are recorded.
