# AngelScript Corpus Authoring Rules

This document is the implementation-time review checklist for `Script/<Theme>/`. It describes reader-facing corpus material, not the independent suites under `Script/Tests/`.

## 1. Theme And File Ownership

- Place a corpus file under exactly one approved root theme: `Language`, `Math`, `Containers`, `Text`, `Reflection`, `Objects`, `Inheritance`, `Interface`, `Delegates`, `Actor`, `Component`, `World`, `Subsystems`, `Timers`, `Input`, `Collision`, `UI`, `Animation`, `Assets`, `Networking`, `Diagnostics`, `Interop`, `BlueprintLibraries`, or `Bindings`.
- Use a PascalCase capability filename that describes the real task, such as `InventoryIndex.as`, `CameraOrientation.as`, or `HealthComponentLifecycle.as`.
- Do not use phase, ticket, fixture, smoke, compat, probe, or coverage terminology in corpus filenames or public symbols.
- Keep globally reflected type names unique across the entire script root. Prefer domain names such as `AHealthLifecycleExampleActor` over generic names such as `AExampleActor`.
- A file owns one primary capability or one cohesive workflow. Split unrelated API families even when they share a bind provider.

## 2. Required Source Card

Every corpus `.as` file starts with a leading block comment containing all four fields:

```text
Purpose: <the concrete developer problem this file solves>
Demonstrates: <the AS-facing language/API features exercised>
Prerequisites: <None or exact World/asset/editor/network requirements>
Expected result: <the observable return, state change, event, or log>
```

Rules:

- `Purpose` describes a user task, not “test X” or “show syntax.”
- `Demonstrates` uses AS-facing names verified against actual bindings or reflection.
- `Prerequisites` says `None` only when the file compiles and its entry path can run without external setup.
- `Expected result` is precise enough for a reader to recognize correct execution.

## 3. API Usage Tables

API-dense corpus files add this Markdown-style table inside the same leading comment:

```text
AS API | Purpose | Important parameters / effects | Used by | Limits | Evidence
```

The table is required for:

- FMath and UE math value types;
- TArray, TMap, TSet, Optional, range, and iterator examples;
- FString, FName, FText, formatting, date/time, GUID, and path examples;
- UObject/reference wrappers and reflection helpers;
- Actor, Component, World, Subsystem, Timer, Input, Collision, UI, Animation, Assets, Networking, and Interop examples.
- every BlueprintLibraries and Bindings corpus file.

Each row must:

1. name the exact AS spelling/signature or a concise unambiguous overload form;
2. explain the operation's purpose rather than repeat its name;
3. identify important mutation, allocation, return, WorldContext, lifetime, or callback effects;
4. name a real function or class in the same file that uses it;
5. state relevant unsupported, reflective-only, editor-only, asset-bound, or network-bound limits.
6. cite the publishing `Bind_*.cpp`, reflected/function-library declaration, and representative Bindings or FunctionLibraries test source.

Evidence order:

1. actual `Bind_*.cpp`, generated/reflected declaration, or function-library header;
2. nearby Bindings/FunctionLibraries AS-visible contract test;
3. Coverage/Functional behavior test;
4. current-fork documentation only as supporting context.

Never copy a C++ registration callback name, native helper name, or Unreal C++ API into the table without confirming the published AS form. Never list an operation solely because a similarly named UE method exists.

BlueprintLibraries files add a short `Library surface` note above the table that states the actual published AS namespace/class/receiver and whether WorldContext is implicit. Bindings files add a `Binding behavior` note stating the user-visible mechanic being taught. Native `UKismet*`, registrar, thunk, and helper names may appear only in `Evidence` or explanatory notes, never as claimed AS syntax unless that exact form is genuinely published.

## 4. Function And Scenario Quality

- Give every public function a name that states its result or effect: `BuildInventoryIndex`, `NormalizeAimRotation`, `ScheduleRespawn`, or `CollectAttachedDamageableActors`.
- Use meaningful input names and domain data. Explain non-obvious constants next to their declaration.
- Produce an observable return, object state, event, delegate callback, component state, World state, or useful log summary.
- Prefer a small realistic workflow over isolated calls: add/query/update/remove, spawn/configure/tick/destroy, bind/broadcast/unbind, or load/inspect/use.
- Keep deterministic behavior. Use fixed seeds for random streams; use bounded ranges only when teaching a random API; never depend on wall-clock timing for correctness.
- Do not hide the taught operation in an opaque helper. Helpers remove incidental setup, not the reason the example exists.

Forbidden corpus patterns:

- `FPhase2*`, `FixtureValue`, `Step()` with no domain meaning, or arbitrary constant-return functions;
- empty functions/classes that exist only to compile;
- `Assert*`, `ExpectError*`, `UAngelscriptTestSuite`, or `FAngelscriptTest` usage;
- test-only native types from `AngelscriptTest`;
- a loop that logs every element without a meaningful summary or reader need;
- an API list with no executable path demonstrating the principal operations.
- a BlueprintLibraries file that copies a domain example without adding a distinct library-composition workflow;
- a Bindings file whose public symbols are named after registrar phases, native thunks, generic call routes, or C++ test fixtures.

## 5. Logging

- Use `Log` for a meaningful input, lifecycle transition, decision, or final outcome that helps a reader follow execution.
- Use `Print` only when on-screen feedback is the feature being demonstrated.
- Prefix complex corpus logs with `[ScriptCorpus.<Theme>.<Scenario>]`.
- Prefer one summary log over one line per loop iteration.
- Logs do not replace a return value or state change when the example can expose one.
- Never emit warnings/errors in a normal successful example merely to make output visible.

## 6. Dependencies And Environment

- Use automatic module dependency discovery; do not use `#include` or compatibility `import` statements.
- Do not depend on `Script/Tests/**` or `AngelscriptTest` test-only fixtures.
- Keep a no-asset path when the API supports one.
- When an asset is essential, document the exact class/type and assignment needed; do not use an unexplained project-local asset path as the only workflow.
- When a World is essential, state how the caller obtains it and which lifecycle phase is valid.
- Network examples state authority/role expectations and never imply that a local function call proves RPC routing.
- Editor-only APIs are wrapped with `#if EDITOR` and identified as editor-only in the source card/table.

## 7. Catalogue Entry

Every curated corpus file has exactly one row in `Script/README.md` with:

| Field | Required content |
|---|---|
| Theme | Approved root theme |
| File | Relative clickable path |
| Purpose | Same user outcome as the source card, summarized |
| Main symbols | Reader entry functions/classes |
| Prerequisites | None or exact setup |
| Expected result | Observable outcome |
| Script tests | Related themed prefix or `Independent` with reason |
| Evidence | Bind provider/function library and representative C++ test |

For `BlueprintLibraries` and `Bindings`, `Evidence` lists the logical provider family, exact source files, and representative `Angelscript.TestModule.Bindings.*` or `Angelscript.TestModule.FunctionLibraries.*` prefix. The catalogue links back to the dominant domain file when a library/binding case is a specialized view of a broader workflow.

The catalogue does not reproduce the full API table. It points readers to the owning file.

## 8. Review Checklist

Before accepting a corpus file:

- [ ] The file is in the correct theme and its reflected names are globally unique.
- [ ] All source-card fields are specific and truthful.
- [ ] Every API-table row has bind/reflection and test evidence.
- [ ] BlueprintLibraries/Bindings cases map to a logical provider family in the audited crosswalk and do not duplicate a domain workflow.
- [ ] The AS-facing spelling was confirmed rather than inferred from C++.
- [ ] The executable body implements a real task and exposes an observable result.
- [ ] Logs are useful, bounded, and not the only output.
- [ ] Asset/World/editor/network prerequisites are explicit.
- [ ] The file is listed once in `Script/README.md`.
- [ ] A related AS functional test or an explicit independence reason is recorded.
- [ ] Focused compilation/test evidence is fresh for the theme wave.
