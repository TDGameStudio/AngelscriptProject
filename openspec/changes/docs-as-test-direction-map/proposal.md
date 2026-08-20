## Why

AngelScript tests grew by **directory**, not by **question**. The same spelling (operators, `if`/`for`, `TArray`, `FString`, `UFUNCTION`, DefaultComponent, delegates) now lives in Native SDK, Syntax, Coverage, Bindings, and Functional at once, while the axis that is actually missing — the **same program** on VM / Cache V2 / StaticJIT / Runtime JIT — has no owner. Coverage is also absent from the named `All` suite. Authors keep adding to the nearest similar file, so duplication grows and the real holes stay open.

## What Changes

- Publish a **two-axis** map: a **subject ladder** in Unreal PascalCase (`Language.Syntax.Comments`, `Containers.TArray`, `Feature.DefaultComponent`, `Definitions.UClass`, `World.Actor`) owns the AS **code library**; eight kebab-case **question** ids own the unit tests that load those files. The lasting runner is a plugin **COMPLEX framework** (per-leaf session + tools: Engine, Corpus, World, Blueprint). CQTest incubates only. The JSON catalog is one enumerator (`same-as-profile` and compile/execute). World stories use `Session.World()`, not leftover CQTest. Detail: `research/framework-lanes.md`. Do not invent a ninth question named “framework”. Language nests Syntax / Operators / ControlFlow / Literals children so `Language.Syntax` is not a dump leftover. `Containers` holds UE `T*` types; `Feature` holds Unreal AngelScript dialect (`mixin`, Delegates, DefaultComponent, Attach trees, GetX/SetX, `asset … of`, class-body `default`, custom `access`). `world-story` is the main **runtime** coverage: it keeps those **full names** and does not collapse every spawn into `World.Actor`. `World.*` is only the host objects (Actor, Component, `World.Subsystem.*`, Blueprint, Widget). BeginPlay/Tick/EndPlay are how `World.Actor` is tested, not extra subject ids.
- Each new test MUST name one subject id and one question id. The library is stored by subject so UClass/UStruct definition scripts are not copied into a second Actor folder just to compile, and Actor/Component world scripts are not proven only as compile-only class snippets.
- Record which physical trees own each question today, which overlaps are allowed, and which are duplicates to stop feeding.
- Record the incomplete axes (same-AS × engine profile, teaching `Script/`, Syntax form extraction, Coverage suite discoverability, optional Runtime JIT) without moving C++ in this change.
- Point existing sibling OpenSpec changes (`test-as-data-driven-engine-harness`, `test-as-syntax-fixture-corpus` when created, HotReload corpus, host `Script/` corpus) at this map so they do not invent a ninth taxonomy. **Math / `FMath::` TestCorpus extract is blocked** until `improve-as-library-namespace-canonicalization` archives; do not keep `Gameplay.Math` or `Math::` as the current library spelling.
- On apply: fold the map into `TestConventions.md` / `UnitTest.md` / test-module guides, and add a named Coverage suite plus an `All` prefix. **No** wholesale directory rename or test deletion in this change.

## Capabilities

### New Capabilities

- `as-test-direction-map`: Subject ladder for the AS library, eight question ids for tests, COMPLEX session + tools versus CQTest incubator, catalog enumerator, CQTest-then-graduate, one-owner-per-question, allowed vs forbidden overlap, and where new tests MUST land.

### Modified Capabilities

- None. Bindings-vs-Coverage (`as-bindings-test-execute-and-naming`) and Coverage matrices (`test-coverage`) stay. This map tells authors **which library subject and which question** to pick; it does not rewrite those specs' oracles.

## Impact

- Docs: `Documents/Guides/TestConventions.md`, `Documents/UnitTest/UnitTest.md`, `Documents/Guides/Test.md`, `Documents/Knowledges/ZH/Test_Layering.md`, `Plugins/Angelscript/Source/AngelscriptTest/TESTING_GUIDE.md`, `AGENTS_ZH.md` at apply time.
- Suite: `Tools/Shared/TestSuiteDefinitions.ps1` — add Coverage as a named suite and to `All`.
- No plugin production code. No mass move of `Syntax/` / `Coverage/` / `Bindings/` files.
- Sibling test-authoring changes consume this map; they remain the movers of AS source onto Fixtures.
