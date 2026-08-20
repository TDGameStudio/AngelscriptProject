# Authored unroll vs generated products

Evidence for Decision 9 in `design.md`.

## SDK generate

`AngelScriptSDK/Support/AngelscriptNativeCaseTestSupport.h` defines `FNativeTypeCase` (18 catalog names: `int8` … `null`) and product evidence flags (`Compile`, `Bytecode`, `Metadata`, …).

`AngelScriptSDK/Support/AngelscriptNativeLanguageCaseTestSupport.h` provides `AppendGeneratedAsLine` and `PrintGeneratedAsSource`, which wrap generated AS in `[AS-SOURCE-BEGIN]` / numbered lines / `[AS-SOURCE-END]` without stuffing the whole corpus into the CQTest result payload.

`Language/Operators/AngelscriptNativeBitwiseOperatorTests.cpp` is the canonical product:

- Axes: 6 operators × 7 right partitions × 5 operand categories × integral `FNativeTypeCase` rows
- `BuildBitwiseSource(TypeCase, CategoryCase)` emits observers, optional field/temporary helpers, then `EvaluateBitAnd` / `ObserveBitAndType` per operator
- `CompileAndReport` builds a product id `LANG-OP-INTEGRAL-BITWISE-SOURCE/<type>/<category>` and dumps source before compile
- Leftover hand samples are marked `AS_NATIVE_NON_PRODUCT` because a generator already superseded them (`AngelscriptNativeConversionsTests.cpp`)

This is the right tool when missing a cell is a coverage bug.

## Coverage unroll

`Coverage/` is 90 files / 1022 `TEST_METHOD`s indexed by `openspec/changes/test-coverage/coverage-matrix.md`. Two shapes live in the same directory:

1. **True scenarios** — `AngelscriptCoverageTArrayAdvancedTests.cpp` `TArraySortAndReverse` authors a `UCLASS` Actor, `UPROPERTY TArray<int>`, `BeginPlay` that `Sort()`s. There is no type table that should emit this.
2. **False unroll** — `AngelscriptCoverageIntExpressionTests.cpp` `LocalDeclarations` pastes `LocalInt8` … `LocalUInt64` as named functions in one `ASTEST_AS` block. That is an 8-wide type product written by hand so each function can be a matrix row. It should become a generator if/when migrated onto the harness.

Coverage also uses `FAngelscriptEngine` and UE binds; SDK products use raw `asIScriptEngine`. Copying SDK generators into Coverage (or the reverse) would test the wrong engine.

## What to do

| Kind | Keep as | Harness |
|---|---|---|
| Unique UE scenario (Actor Sort, mixin, Widget, FString.Find) | Authored `.as` / existing CQTest | Optional later file extraction; do not generate |
| Homogeneous type×op product on raw SDK | Existing SDK generator | Do not duplicate into Fixtures |
| Same product also needs Cache/JIT/`FAngelscriptEngine` | New harness generator leaf with product id | Wave A golden: `integral-bitwise` on shared `vm` only |
| Coverage int-family copy-paste (Expression/Function axes) | Leave in Coverage until Wave B | Migration = Coverage generator, not 8 fixture files; see `coverage-generation.md` |
| Coverage Property family (Pattern D) | Leave in Coverage until spawn+`VerifyByPath` observations exist | Do not fake with script getters |
| Coverage matrices 10–18 | CQTest | Out of this change |

Do not check in `Fixtures/Generated/int8_bitand.as` through `uint64_shift.as` in v1. Dump generated source on failure instead.

Full 18-domain table: `coverage-generation.md`.
