# AST-first test gate

## Purpose

This attachment turns the canonical typed-AST test strategy into a working
quality gate for `refactor-as-canonical-typed-ast-compiler`. The migration's
deliverable is a semantic representation, not merely a second way to get a VM
result. Therefore source-to-VM tests are necessary final evidence but cannot
be the first or only evidence for a change to the representation.

The gate was added on 2026-08-23 after three current issues made the failure
mode concrete:

| Semantic issue | First trustworthy assertion | Downstream proof |
| --- | --- | --- |
| A `const` inside `const int &in` was treated as a trailing method `const` | Sema stable key and `asAST_TRAIT_CONST_METHOD` assertions | const/non-const overload executes the selected bodies |
| Member-call lookup ignored receiver constness | canonical CALL's resolved callee and receiver type | mutable and const calls return different values |
| Native `ETeam::Red` became an untyped `int` reference | enum-typed literal / parameter/call assertion | `F(ETeam)` executes without a false unresolved-callee |

The test order prevents a CodeGen patch from accidentally compensating for an
incorrect semantic graph.

## Required sequence

```text
1. Red AST test
      The new case fails while inspecting the sealed canonical graph.

2. Green AST test
      Sema/AST/Seal exposes the exact intended semantic fact.

3. Red-to-green lowering test
      Canonical CodeGen consumes that fact and publishes provenance-correct
      bytecode; execute only where the form is executable.

4. Lifecycle / persistence test
      Add Cache V2, replacement, snapshot, StaticJIT, or Hot Reload coverage
      when the changed fact crosses that boundary.

5. Focused regression
      Run the owning AST suite first, then the owning backend and only then a
      broad compatibility suite.
```

No step may be skipped by citing a legacy compile, a canonical pipeline enum,
a broad SDK result, or a CodeGen dump that did not assert the semantic fact.
If the AST test fails, fix the semantic construction/verification rule. If it
passes and CodeGen fails, retain the AST test and fix lowering/lifecycle rather
than weakening the AST contract.

## Gate matrix

| Change surface | Required front gate | Minimum assertions | Follow-on evidence |
| --- | --- | --- | --- |
| Parser/Sema declaration/type/scope/overload/call/lifetime/control rule | `Compiler.CanonicalAST.SemaAuthority` | node/decl kind, stable key and owner, exact `asCQualType`/qualifiers, trait, resolved callee/arguments, conversion, cleanup/target or diagnostic | `ProductionCodeGen`, then differential/VM case |
| Parser/source/node construction/verifier/dump | `Frontend.CanonicalAST` | source range/provenance, opaque IDs, ownership, graph invariants, deterministic dump, Seal rejection | `SemaAuthority` or CodeGen only if executable behavior is affected |
| Public AST retention/rebuild/reader ownership | `Module.CanonicalAST.Snapshot` and Hot Reload snapshot tests | version/size contract, foreign IDs, immutable lease, current generation and failed-publish preservation | retained CodeGen/rebuild regression |
| Cache V2 AST sidecar or ExactStartup | Cache canonical-AST retention/sidecar tests | DTO contains actual pointer-free semantic facts, post-remap Seal equivalence, content identity, generation ownership | ExactStartup / warm-cache execution |
| Bytecode lowering with no semantic representation change | existing relevant AST test must still be green | the existing AST fact is named in the result record | `ProductionCodeGen`, transaction/lifecycle regression |

The standard commands use group prefixes, which are robust to the C++ test
class segment that appears in full automation paths:

```powershell
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.SemaAuthority" -Label <label> -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Frontend.CanonicalAST" -Label <label> -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot" -Label <label> -TimeoutMs 900000
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen" -Label <label> -TimeoutMs 900000
```

When targeting one method, take its exact `fullTestPath` from a previous
automation report. CQTest places the C++ class name between the registration
prefix and method name, for example:

```text
Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen
  .FCanonicalASTProductionCodeGenTests
  .CanonicalSwitchFallthroughExecutesNextCase
```

This avoids treating a no-match runner error as a compiler regression or a
passing test.

## Evidence record required for each slice

Each attachment or task-progress update records:

1. Behavior and the canonical fact that defines it.
2. Test source/path and exact assertion (not only test name).
3. Red result or a source-level demonstration why the rule was previously
   absent; old already-green behavior must not be presented as new coverage.
4. Green focused AST gate: command, artifact path, pass/fail count.
5. Green CodeGen/provenance result where applicable.
6. Cache/reload/JIT result if the changed semantic fact crosses that boundary.
7. Remaining limits stated separately from the local green result.

## Cutover consequence

Before the default compiler pipeline changes, the final evidence must include a
fresh pass of all rows in the gate matrix. A green All suite while production
still uses `asCCompiler` proves compatibility of that path only. It cannot
prove canonical semantic authority, and it must not close the default-cutover
tasks.

## First enforced slice: resolved floating-point type authority (2026-08-23)

This gate was applied to a real cross-layer defect rather than recorded only as
workflow guidance. The source spelling `float` is configuration dependent in
this fork: with `asEP_FLOAT_IS_FLOAT64=1`, Parser resolves it to
`ttFloat64`. Canonical Sema then incorrectly formatted that resolved token
back to the spelling `float` and reparsed it as the old `ttFloat` primitive.
The separate `float32` / `float64` spellings were also not recognized by the
string entry point. Consequently an AST `const float` global could carry an
inconsistent type and raw storage value before CodeGen saw it.

The AST-first sequence was:

```text
source: const float DefaultWidth = 2.5
  ↓
red sealed-AST gate: global initializer was not a valid resolved float constant
  ↓
repair: preserve Parser's primitive token; recognize float32/float64; freeze
        constant bytes using the resolved width
  ↓
green AST: type token + constant bits are exact
  ↓
green CodeGen: namespace global initializes and the generated function returns 2.0
  ↓
green Cache V2: sidecar restores ttFloat32/ttFloat64 and their raw bytes exactly
```

Permanent tests and asserted facts:

| Layer | Test | Facts asserted |
| --- | --- | --- |
| AST authority | `AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` — `CompileSealFloatGlobalConstantsFreezeResolvedStorageWidths` | Source `float` resolves according to engine policy; explicit `float32` and `float64` retain their exact primitive tokens; all three constant globals retain exact raw storage bits. |
| CodeGen / execution | `AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` — `CanonicalFloatNamespaceGlobalInitializesExecutesAndPublishesCodeGen` | Retained AST records the resolved default type, canonical Bytecode CodeGen publishes the canonical provenance, and `Game::Read()` returns the initialized `double` value. |
| Cache V2 | `Cache/AngelscriptCacheASTBodySidecarTests.cpp` — `SidecarRoundTripPreservesResolvedFloatWidthsAndConstantBits` | Pointer-free AST sidecar decode preserves `ttFloat32`, `ttFloat64`, const qualification, and raw `3.25f` / `4.5` bit patterns without re-running Sema. |

Evidence from this worktree (`D:\as-cta`):

| Stage | Result | Evidence |
| --- | --- | --- |
| Initial AST red | `0/1` — `global-init-not-constant` before the resolved-token fix | `Saved/Tests/cta-canonical-float-widths-literal-red/20260823_155142_634_bb50a012/RunMetadata.json` |
| Focused AST green | `1/1` | `Saved/Tests/cta-canonical-float-widths-ast-green/20260823_155725_531_5f663d38/RunMetadata.json` |
| Full semantic gate | `253/253` | `Saved/Tests/cta-canonical-sema-authority-float-green/20260823_160727_009_c78cd425/RunMetadata.json` |
| Full CodeGen gate | `69/69` | `Saved/Tests/cta-canonical-production-codegen-float-final/20260823_160809_965_2b376fe0/RunMetadata.json` |
| Cache V2 AST sidecar | `11/11` | `Saved/Tests/cta-cache-v2-float-sidecar-green/20260823_161026_740_69e1441a/RunMetadata.json` |

The key process lesson is that **source spelling is not canonical semantic
identity**. Tests originating from script text must assert the engine-resolved
canonical fact (here, `double` under the active float policy), while tests that
construct `ttFloat` directly must explicitly assert float32 behavior. Treating
those as the same assertion caused fourteen Sema tests to encode an obsolete
spelling contract; after splitting the contracts, the group recovered from
`239/253` to `253/253` without weakening the semantic requirement.

This does not mark the production default-pipeline tasks complete. It is the
model for evidence expected before each remaining cutover slice is allowed to
advance to lowering, persistence, or broad compatibility testing.

## Second enforced slice: mixed-width comparison and return-ABI normalization (2026-08-23)

The first slice made source `float` truthful: under this Engine configuration
it is `float64`. Applying the gate to the existing CanonicalAST behavior matrix
then found two independent follow-on defects that the old accidental
`float32` representation had masked:

1. `v > 0.5f` had a float64 left operand and float32 right literal, but the
   sealed binary expression retained the historical `int` placeholder result
   and no widening conversion. `as_bytecode_codegen` consequently issued
   `CMPi` for every comparison.
2. A function declared `float` could return `2.0f` as a float32 expression.
   The active incremental Parser/Sema statement path did not insert the
   signature-width conversion before CodeGen copied the value into the
   float64 ABI return slot. Fixing a separate declaration-walker path alone
   did not help; the AST test showed that the current path is
   `as_sema_stmt.cpp`.

The completed gate sequence is deliberately layered:

```text
source: float v = ...; return v > 0.5f
        float ReturnNarrow() { return 0.5f; }
                    │
                    ▼
red AST gates
  - binary operands disagree; result is historical int
  - return expression does not match function's resolved signature width
                    │
                    ▼
sealed AST repair
  - numeric operands normalize to a common width
  - float32 literal remains below explicit float64 conversion
  - comparison result is bool
  - primitive return expression matches the function signature
                    │
                    ▼
CodeGen repair
  - emit CMPf / CMPd / signed / unsigned compare from normalized operand type
  - CopyValue receives a slot whose type and ABI width already agree
                    │
                    ▼
Cache V2 + broad VM/differential execution
  - sidecar preserves conversion child, both widths, and bool result
  - legacy/canonical mismatched conditional-arm trace agrees on both arms
```

Permanent tests and asserted facts:

| Layer | Test | Facts asserted |
| --- | --- | --- |
| AST authority | `AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` — `CompileSealDefaultFloatComparisonNormalizesOperandWidths` | For `float64Value > 0.5f`, both sealed operands have the resolved common width, the right child is an explicit conversion from the original float32 literal, and the binary result is `ttBool`. |
| AST authority | the same file — `CompileSealDefaultFloatReturnNormalizesToSignatureWidth` | A function's primitive return expression has its resolved signature type before ABI lowering; under the active policy the float32 literal is retained beneath an explicit float64 conversion. |
| CodeGen / differential execution | `AngelScriptSDK/Compiler/CanonicalAST/Semantics/AngelscriptNativeCanonicalASTVmMatrixTests.cpp` — `IsolatedConditionalMismatchedArmsMatchesLegacyCanonicalTrace` | Canonical CodeGen executes both conditional arms with the same return values and trace as legacy; this is the execution case that first exposed `CMPi` and then the narrowed return-slot copy. |
| Cache V2 | `Cache/AngelscriptCacheASTBodySidecarTests.cpp` — `SidecarRoundTripPreservesMixedWidthComparisonNormalization` | A pointer-free sidecar preserves the float32 source literal, float64 conversion, float64 operands, `>` operator, and bool comparison result without re-running Sema. |

Evidence from this worktree (`D:\as-cta`):

| Stage | Result | Evidence |
| --- | --- | --- |
| Comparison AST red | `253/254` — only `CompileSealDefaultFloatComparisonNormalizesOperandWidths` failed | `Saved/Tests/cta-float-compare-ast-red/20260823_161833_687_e4f14ca3/RunMetadata.json` |
| First broad execution diagnosis | `349/350` — `IsolatedConditionalMismatchedArmsMatchesLegacyCanonicalTrace` failed | `Saved/Tests/cta-canonical-ast-first-gate-full-regression/20260823_161150_940_8b74758c/RunMetadata.json` |
| Return-ABI AST red | `254/255` — only `CompileSealDefaultFloatReturnNormalizesToSignatureWidth` failed | `Saved/Tests/cta-float-return-ast-red/20260823_162530_148_08958ede/RunMetadata.json` |
| Focused return AST green | `1/1` | `Saved/Tests/cta-float-return-ast-green/20260823_162946_313_d95f04e4/RunMetadata.json` |
| Final Sema authority gate | `255/255` | `Saved/Tests/cta-ast-first-sema-authority-final/20260823_163115_837_ba2823f5/RunMetadata.json` |
| Final Production CodeGen gate | `69/69` | `Saved/Tests/cta-ast-first-production-codegen-final/20260823_163158_566_02be98ea/RunMetadata.json` |
| Final Cache V2 sidecar gate | `12/12` | `Saved/Tests/cta-ast-first-cache-v2-final/20260823_163236_706_087aa406/RunMetadata.json` |
| Final CanonicalAST behavior regression | `352/352` | `Saved/Tests/cta-canonical-ast-first-gate-full-regression-final/20260823_163026_157_e04ab4a5/RunMetadata.json` |

The process lesson is stricter than “add more VM tests”: **the AST gate must
run before the lowering test, and it must be retained when the first lowerer
bug is fixed.** In this slice the first sealed-AST assertion correctly exposed
comparison normalization. Once that was green, the existing runtime matrix
isolated a separate return-ABI failure; a second sealed-AST assertion then
identified the exact active Parser/Sema route that had been omitted. This is
the intended feedback loop for the remaining migration: never lower around a
missing AST fact, and never assume a fix on a legacy/secondary walk protects
the current canonical action path.
