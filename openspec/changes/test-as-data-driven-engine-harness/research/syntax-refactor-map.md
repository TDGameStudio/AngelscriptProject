# Syntax/ authoring refactor map

Scan of `Plugins/Angelscript/Source/AngelscriptTest/Syntax/` (2026-08-18). Counts are order-of-magnitude, not TestCatalog.

Related: sibling change `test-as-data-driven-engine-harness` (corpus API + OptionalEmpty golden). This map is the Syntax extraction plan; it is **not** a new engine-profile COMPLEX.

Direction id: `surface-form` (`docs-as-test-direction-map`). Do not add new packed `ExpectGlobalInts` that duplicate Coverage language/int rows. After extraction, language-only packed modules may be consumed by `same-as-profile` (`vm`).

## What Syntax actually is

19 `.cpp` files, 141 `TEST_METHOD`s, ~581 `TEXT(R"(` blobs.

| Oracle | Count | Helper |
|---|---|---|
| Compile success | 210 | `AssertCompiles` |
| Compile fail, **no** message | 352 | `AssertFailsToCompile` |
| Compile fail + substring | 8 | `AssertFailsWithError` |
| Compile + warning | 0 | unused |
| Preprocessor compile | 0 | unused |
| Execute packed module | 13 modules / 13 `ExpectGlobalInts` | `FScopedAngelscriptModule` |

Line/column is **not** the oracle. Helpers only require diagnostic `Row > 0`. Extracting to files does not break Syntax the way it would break `Compiler/` / `Preprocessor/`.

Most tests still need a **Full** `FAngelscriptEngine` with UE binds (`AActor` 244, `UPROPERTY` 146, `UFUNCTION` 57, `DefaultComponent` 49). They do **not** need World/Actor spawn. They stay Syntax, not Functional, not Bindings.

Light suite prefix `Angelscript.TestModule.Syntax` already exists. Keep it.

## Three shapes in the current cpp

1. **Packed execute** — one `TEXT(R"(` with many global functions, then `ExpectGlobalInts`. Only `Operators` and `ControlFlow` (plus a little `TypeDeclaration`). This is the OptionalEmpty-like unit.
2. **Packed compile-only** — one `TEST_METHOD` calls `AssertCompiles` / `AssertFailsToCompile` many times, each with its own snippet and fake `{SectionName}.as`. Access, Casting, Container, FString, Math, Misc, Mixin, TypeDeclaration, UFunction, UProperty.
3. **One method, one snippet** — DefaultComponent (19), DelegateEvent (25), PropertyAccessor (3), NamespacedUSTRUCT (1). Cleanest 1:1 file mapping.

`#if 0` / `DISABLED(#as-engine-behavior)` snippets (Mixin positives, some operator negatives) are **not** live fixtures. Do not extract them as catalog cases.

FString escape uses `TEXT("...")` instead of `R"(` because of `\n\t`. A file helps.

## Approaches

### A. Files + keep CQTest (recommended)

Authored `.as` under `Fixtures/Syntax/<Theme>/`. CQTest loads via `FAngelscriptTestScriptCorpus::TryGetByRelativePath`. Helpers gain a corpus overload. Prefix, suite, and `SyntaxTestHelpers` stay.

- Pros: Matches Decision 16; no GetTests explosion; negatives keep fail-without-substring; UE-dialect stays compile-only on shared engine.
- Cons: 500+ files if everything is extracted; cpp still exists as the driver.

### B. Dump every snippet onto DataDriven COMPLEX

~560 catalog cases under `Angelscript.TestModule.DataDriven.Syntax.*`.

- Pros: One driver, later cache/JIT is a JSON profile add.
- Cons: Replaces 141 filterable methods with hundreds of compile-only leaves; harness `compile` fail today is substring-oriented (only 8 Syntax cases have fragments); cartesian temptation; duplicates OptionalEmpty's job.

### C. Generate Syntax from operator/type tables

- Rejected. Syntax snippets are unique forms (UFUNCTION specifiers, DefaultComponent attach cycles, access specifiers). Homogeneous type×op already belongs to Coverage / product generators.

## Locked direction

**A, in waves.** DataDriven is a later **optional consumer** of the language-only execute files, not the Syntax driver.

Do not:

- Create `FAngelscriptSyntaxCorpusAutomation` (third COMPLEX).
- Cartesian Syntax × cache/JIT in the first Syntax change.
- Move UFUNCTION/DefaultComponent into Bindings or Functional.
- Require diagnostic substrings for the 352 fail-without-message cases.
- Extract `#if 0` snippets as live fixtures.
- Start before `FAngelscriptTestScriptCorpus` is green.

## File layout

```text
Plugins/Angelscript/Source/AngelscriptTest/Fixtures/Syntax/
  Operators/arithmetic-positive.as          # packed execute (shape 1)
  Operators/arithmetic-str-plus-int.as      # one negative snippet
  ControlFlow/if-else-positive.as
  UFunction/basic.as
  DefaultComponent/basic.as
  PropertyAccessor/property-decorator.as    # fail + substring
  NamespacedUSTRUCT/duplicate-short-name.as
```

Virtual path: `/Angelscript/Memory/TestCorpus/Syntax/<Theme>/<file>.as`.

Compile identity for helpers: relative path as filename (replace fake `{SectionName}.as`). Module name: sanitized relative path, unique per snippet, still `ResetModules` after the method.

Granularity:

- Shape 1 stays **one file per packed module** (do not split `AddInt` / `SubInt`).
- Shape 2/3: **one file per `Assert*` snippet**.

`Fixtures/Syntax/cases.json` is **not** required for Wave 1–3. OptionalEmpty already lives there as the harness golden; do not overwrite it. Later Wave 4 may add a **small** catalog only for packed execute files that list extra profiles.

## Helper change

Keep `AssertCompiles(Source)` for one-off leftovers. Add:

```text
AssertCompilesFromCorpus(Test, Engine, RelativePath, Description)
AssertFailsToCompileFromCorpus(...)
AssertFailsWithErrorFromCorpus(..., ExpectedErrorFragment, ...)
```

Implementation: `TryGetByRelativePath` → existing `CompileModuleWithSummary`. On failure, dump the relative path and `[AS-SOURCE-BEGIN]` like the harness.

Execute packed modules: `TryGetByRelativePath` → `FScopedAngelscriptModule` + existing `ExpectGlobalInts`. CQTest methods keep the expected-int tables in C++ (or a sibling `.json` only if a later DataDriven case needs the same oracles). Wave 1 keeps expected ints in the cpp.

## Waves

Blocked on harness task 2 (`FAngelscriptTestScriptCorpus`).

| Wave | What | Verify |
|---|---|---|
| 1 | Packed execute: `Operators` + `ControlFlow` positives (and any `TypeDeclaration` execute module) | `Angelscript.TestModule.Syntax.Operators` and `.ControlFlow` |
| 2 | Remaining `AssertCompiles` positives, including UE dialect | per-theme Syntax prefixes |
| 3 | Negatives (fail-without-substring + the 8 fail-with-substring) | full `Angelscript.TestModule.Syntax` |
| 4 (optional, later) | Language-only packed execute files MAY add explicit DataDriven `vm` / `cache-roundtrip` / `typed-ast-generate` leaves. UFUNCTION / DefaultComponent / access-on-AActor stay CQTest compile-only. | DataDriven + Syntax dual-run, then decide whether to drop cpp execute |

Dual-run each wave: cpp still discovers the same `TEST_METHOD` names until the inline `TEXT(R"(` is gone. Do not delete a method in the same step that first points it at a file.

## Suggested OpenSpec name

`test-as-syntax-fixture-corpus` — not created in this scan. Tasks should name exact `Tools\RunTests.ps1 -TestPrefix` commands per theme. Chinese-first docs at apply time.
