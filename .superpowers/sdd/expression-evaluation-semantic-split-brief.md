# Expression evaluation semantic-owner split brief

## Scope and frozen baseline

Refactor only:

`Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Language/Expressions/AngelscriptNativeExpressionEvaluationTests.cpp`

This is a behavior-preserving physical split between opposite expression
execution responsibilities. Do not change any generated case, source ID,
source text, execution oracle, diagnostic, lifecycle, or cleanup behavior.

Frozen current baseline:

- file SHA-256:
  `b743ffc8915b338408cbb16b3c3d326cb0531a143bc15872f21884bfcd68eb81`;
- 1 class / 2 methods / 2 products;
- 612 catalog cases: 72 lazy and 540 eager;
- 54 static `ASSERT_THAT` sites, 27 attributable to each target owner;
- 2 static `PrintGeneratedAsSource` sites, one per method;
- 2 case-owned engine Create/Destroy pairs;
- 2 context Create/Unprepare/Release paths;
- 2 module discard paths;
- no class-owned engine or CQTest lifecycle hook.

Method sequence SHA-256:

`a3bd9a46fa58ed6dbc43ade3270313ece3d2cfd83a33fa51db70095466e1e517`

Product sequence SHA-256:

`dc9ff22e92ed33d2884562c45cb273c45908f0242d15a6237824a71346229738`

Inclusive-brace method hashes use LF normalization, per-line trailing
horizontal-whitespace removal, whole-block strip, UTF-8, SHA-256:

- `LazyFormsBySelectorOutcomeAndShape`:
  `8cec00ff3981cdee207db1dc27740ebbeb19e535f4458b454236a0f72b0b54b2`
- `CompositionsByCountOutcomeAndSourceShape`:
  `7701e1000dae1f1ec27ac6c1e75014126f46f87a798727784e70a90aeb4700aa`

Both complete method bodies must remain byte-preserved so these hashes still
match after the move.

## Required physical owners

Retire the aggregate and create:

1. `Language/Expressions/AngelscriptNativeLazyExpressionEvaluationTests.cpp`
   - class `FLazyExpressionEvaluationTests`
   - method `LazyFormsBySelectorOutcomeAndShape`
   - product `LANG-EXPR-LAZY-EVALUATION`
   - 72 cases
   - 27 assertion sites
   - 1 static source-print site
2. `Language/Expressions/AngelscriptNativeEagerExpressionOrderTests.cpp`
   - class `FEagerExpressionOrderTests`
   - method `CompositionsByCountOutcomeAndSourceShape`
   - product `LANG-EXPR-EVAL-ORDER`
   - 540 cases
   - 27 assertion sites
   - 1 static source-print site
3. `Support/AngelscriptNativeExpressionEvaluationTestSupport.h`

Both classes retain the exact Automation directory:

`Angelscript.TestModule.AngelScriptSDK.Language.Expressions.Evaluation`

The class portion of the full leaf necessarily changes to the two unique
classes; do not reuse the same class name in both `.cpp` files because unity
compilation would see duplicate definitions.

## Required shared support boundary

The new `#pragma once` header contains only the instrumentation that both
products already use:

- `ExpressionEvaluationRecorderUserDataSlot` as `inline constexpr`;
- `FExpressionEvaluationRecorder`;
- `GetActiveExpressionEvaluationRecorder`;
- `RecordExpressionBool`;
- `RecordExpressionInt`;
- `RecordEagerStage`;
- `CompleteEagerBoundary`;
- `RegisterExpressionEvaluationFunctions`.

Functions must be `inline` and live in
`AngelscriptNativeTestSupport`. Preserve the combined registration behavior:
both product-local engines continue to register all four callbacks exactly as
the aggregate did. Do not narrow registrations as part of a physical move.

Do not move either product's tables, generators, expected-result computation,
marker oracle, context/module flow, or assertions into the shared header.

## Lazy owner responsibility

Keep class-private:

- `FFormCase`, `FSelectorCase`, `FOperandOutcomeCase`,
  `FSourceShapeCase`;
- all four case tables;
- `IsSourceShape`, `MakeSuffix`, `IsGuardedOperandSelected`,
  `MakeGuardedExpression`, `MakeSelectorExpression`,
  `MakeSingleLineExpression`, `AppendExceptionHelpers`,
  `AppendMultilineReturn`, `BuildLazyEvaluationSource`,
  `ExpectedResult`, `ExpectedMarkers`, `VerifyMarkers`;
- the unchanged method body.

Preserve all 72 cells:

`3 forms × 3 operand outcomes × 2 selectors × 4 source shapes`

The owner proves selected execution and skipped-branch non-execution,
selected exception metadata/callstack, exact markers/results, tracked
construction/destruction balance, clean reuse returning 89, and exact module
discard/null lookup.

## Eager owner responsibility

Keep class-private:

- `EEagerComposition`, `EEagerOutcome`;
- all eager case structs and tables;
- all eager shape/order/stage helpers;
- declaration/expression/source builders;
- expected result, markers, exception decision, and marker verifier;
- the unchanged method body.

Preserve all 540 cells:

`9 compositions × 3 operand counts × 4 outcomes × 5 source shapes`

The owner proves the fork's exact forward/reverse evaluation orders, exact
exception cutoff, independent result oracle, marker sequence, tracked
construction/destruction balance, clean reuse returning 137, and exact module
discard/null lookup.

## Lifecycle and style requirements

Each method must keep its existing:

- local `FNativeTestEngine`;
- immediate `ON_SCOPE_EXIT` destroy guard;
- registration and user-data recorder;
- per-cell reset of recorder/lifecycle/messages;
- unique module name;
- context create, execute, `Unprepare`, clean follow-up, and `Release`;
- module discard and exact-name null lookup.

Do not introduce `BEFORE_ALL`, `BEFORE_EACH`, `AFTER_ALL`, class-owned engines,
add-ons, `FAngelscriptEngine`, UE object/world fixtures, or debugger
integration.

Every `.cpp` must have the correct `WITH_ANGELSCRIPT_UNITTESTS` body gate.
Restore `public:` before the `TEST_METHOD` after class-private helpers.
Includes must be self-contained and unity-safe. Use `apply_patch` for all
edits. Do not build, run UE Automation, commit, or touch unrelated files.

## Generated-source registry

Replace the current aggregate row with two focused rows:

- lazy row:
  - current lazy file/class/method/product;
  - generator:
    `BuildLazyEvaluationSource; AppendExceptionHelpers; AppendMultilineReturn; MakeSingleLineExpression`;
  - `PrintSites=1`;
  - formatting/reason describe only stable lazy form/outcome/selector/shape
    order and its 72 cells.
- eager row:
  - current eager file/class/method/product;
  - generator:
    `BuildEagerEvaluationSource; AppendEagerCompositionDeclarations; AppendEagerChainType; MakeEagerCompositionExpression; MakeEagerStageExpressions; MakeEagerCallChain; MakeNestedCastExpression`;
  - `PrintSites=1`;
  - formatting/reason describe only stable eager
    composition/count/outcome/shape order and its 540 cells.

Static print total remains 2; dynamic reports remain 612. Do not write 72 or
540 into `PrintSites`.

## Living and generated records

Update authored current records:

- `catalogs/coverage-products.psd1`
- `catalogs/generated-source-registry.csv`
- `coverage/expressions.md`
- `handoffs/fixture-and-large-file-quality-review.csv`
- `handoffs/fixture-and-large-file-quality-review.md`
- task 4.7 in `tasks.md`

Retire the old quality row and add two `CompliantCaseOwned` / `NotLarge` /
`None.` rows. Expression-local change is one physical owner becoming two,
`CompliantCaseOwned +1`, `NotLarge +2`, and remaining required splits `-1`.
Derive absolute totals from current source after Tokenizer is stable; do not
reuse the earlier 256-file snapshot.

Regenerate canonical current audits with official scripts instead of
hand-editing inventory rows:

- expected rows and product cardinalities;
- current files/methods/assertions/summary;
- implementation and method-product reconciliation;
- API use;
- predecessor current dispositions where the living owner rationale changes.

Preserve historical checkpoint records with the old aggregate path.

## Static verification

Before reporting complete:

- aggregate absent; two `.cpp` and one narrow header present;
- exactly 2 unique classes, 2 methods, and 2 products;
- both method hashes and method/product sequence hashes match;
- exact product/cardinality split is 72 + 540 = 612;
- expected case ID set is unchanged;
- 54 assertion sites remain 27 + 27;
- static print sites remain 1 + 1 and registry has exactly two rows;
- both owners retain one engine Create/Destroy, one
  context Create/Unprepare/Release, one discard, and post-discard null lookup;
- no class-owned engine or lifecycle hook;
- shared header exports only the eight required definitions and contains no
  CQTest registration, product marker, source printing, generator, or oracle;
- lazy source contains no eager tables/builders/oracles and vice versa;
- catalog, source ownership, registry, API, predecessor, internal, boundary,
  inline-AS, planning, strict OpenSpec, unity/global symbols, whitespace/EOF,
  and current quality-record checks pass;
- remaining split count decreases by one from the stable post-Tokenizer value.

If a script invocation fails due to host/runtime or wrong input, correct it
and record the tool problem; do not hide a real source/record failure.

## Report

Write:

`.superpowers/sdd/expression-evaluation-semantic-split-report.md`

Report status, exact files, pre/post counts, hash and case preservation,
static commands/results, problems, and explicit confirmation that no build,
UE Automation, commit, or unrelated edit occurred.
