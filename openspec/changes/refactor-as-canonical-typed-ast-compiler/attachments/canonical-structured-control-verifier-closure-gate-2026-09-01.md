# Canonical structured-control verifier closure gate

Status: **COMPLETE — Task 5.6 closed 2026-09-02**.

This attachment is the AST-first gate card and final evidence record for
OpenSpec Task 5.6. It closes structured statement/control semantics and their
fail-closed publication boundary. It does not close lifetime cleanup on
transfer (`5.7/5.8/7.5/9.5`), complete backend isolation/default cutover
(sections 9, 10 and 13), or the user-deferred Cache V2 restore/product
redesign.

The maintained fork has no production HIR layer. The task's migrated control
evidence is therefore the source-built Frozen/Publishable Canonical AST,
forged verifier graphs, immutable Snapshot/AST Sidecar representation and
Canonical Bytecode execution. No HIR artifact, dump token or LEGACY compiler
result is accepted as a substitute for the sealed semantic facts.

## Gate-card contract

- **Owning tasks:** `5.6`, with overlapping authority evidence for `0.2` and
  `13.2`.
- **AST owner:**
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` plus source-shape
  coverage in Frontend CanonicalAST.
- **Malformed-graph owner:**
  `AngelscriptNativeCanonicalASTVerifierTests.cpp`.
- **Mechanical consumer owner:**
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` and the Semantics
  VM matrix.
- **Lifecycle/persistence owners:** Module CanonicalAST Snapshot and Cache
  `ASTBodySidecar`. Sidecar coverage proves that the pointer-free Canonical AST
  representation preserves the facts; it does not enable or validate Cache V2
  restore as a product path.

The required sealed/public facts are:

1. Break, Continue and Fallthrough have exact structured targets and remain
   leaf transfer statements.
2. If, For and Foreach preserve authenticated source-order phases; malformed
   phase counts and kinds fail before publication.
3. A statement's ordinary/specialized safe-point role is explicit. Loop entry,
   Call, Return and exhaustive-enum invalid-value roles are not reconstructed
   by a backend.
4. Every non-default Case carries a Sema-authored, selector-domain 32-bit
   constant fact. Duplicate analysis consumes the normalized fact, not the
   authored expression spelling.
5. Wrong-kind, non-ancestor, skipped-nearer, dangling, duplicate Case,
   default-order, invalid fallthrough and duplicate structural incoming-edge
   graphs fail closed.
6. A diagnosed source graph is analyze-all/commit-none: no publishable AST,
   Runtime function, Bytecode publisher or retained snapshot may escape.

## Retained RED-to-GREEN semantic slices

### Selector-domain normalized duplicate Case values

- **Source fixtures:** `switch (uint Selector)` with `case 1` and
  `case uint(1)` for duplicate rejection, plus `case uint(2)` for the distinct
  control.
- **Exact tests:**
  `MixedExactTypeDuplicateCaseFailsInSelectorDomainWithoutLegacyCompiler`,
  `NarrowedConstantDuplicateCaseFailsInSelectorDomainWithoutLegacyCompiler`,
  `MixedExactTypeDistinctCasesSealSelectorDomainConversions`, and the forged
  normalized-domain verifier rows beginning at
  `RejectsDuplicateCaseAndDefaultNotLast`.
- **Sealed facts:** each Case owns an explicit authenticated
  `switch-case-domain` Conversion/fact with selector type, literal bits and
  source provenance. The authored child remains source evidence only.
- **Authentic RED examples:**
  `Saved/Tests/cta-s179-task56-conversion-duplicate-red/`
  `20260901_220635_722_f7b73630` and
  `Saved/Tests/cta-s179-task56-codegen-authority-red5/`
  `20260902_000156_273_f7beb309`.
- **GREEN:** the verifier compares normalized facts; Canonical Bytecode
  materializes the authenticated Case constant and does not execute the
  authored provenance child. The final owner results are listed below.

### Typed Case evaluator and diagnostic recovery

- **Source fixture families:** signed/unsigned 32/64-bit shifts, `>>`/`>>>`,
  integer power, local readonly and mutable-global provenance, explicit
  float-to-integer conversion, divide/modulo recovery, engine integer-division
  policy, enum constantness, same-value enum duplicates and cross-enum type
  checking.
- **Sealed facts:** the evaluator returns a typed result that distinguishes a
  valid integral constant, nonconstant, nonintegral constant and diagnosed
  error. It walks all required operands/branches for diagnostics and commits
  wrappers only at the aggregate success boundary.
- **Authentic RED:** operator/provenance **0/5** at
  `Saved/Tests/cta-s179-task56-constant-subset-red2/`
  `20260901_234351_125_d7df4012`; edge/diagnostic **0/3** at
  `Saved/Tests/cta-s179-task56-constant-edge-red/`
  `20260901_234838_108_c1fd0e8c`; mutable-global broad RED **563/564** at
  `Saved/Tests/cta-s179-task56-sema-current/`
  `20260902_013649_855_83a9e332`.
- **GREEN:** retained Sema tests authenticate the exact type, constant bits,
  provenance and no-publication behavior; final SemaAuthority is **566/566**.

### Cross-enum mismatch continues duplicate diagnosis

- **Exact test:**
  `CrossEnumCaseMismatchContinuesDuplicateDiagnosisWithoutPublishing` in
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`.
- **Source fixture:** an enum selector, an earlier selector-enum Case and a
  later Case from a different enum with the same normalized signed 32-bit
  value, under `asEP_TYPECHECK_SWITCH_ENUMS=1`.
- **Asserted facts:** the nominal mismatch diagnostic precedes
  `Duplicate switch case`; the build fails with publisher `NONE`, zero LEGACY
  compiler invocations, no `Entry` function and no retained snapshot.
- **Authentic RED:**
  `Saved/Tests/cta-s180-cross-enum-recovery-red/`
  `20260902_015652_174_d61ce4be`.
- **Focused GREEN:** **1/1** at
  `Saved/Tests/cta-s180-cross-enum-recovery-green/`
  `20260902_015759_680_c65f62c5`.
- **Production rule:** record the mismatch as diagnosed, continue numeric
  normalization and duplicate analysis, then refuse graph commit at the
  aggregate diagnosed boundary.

### Case-sensitive `MAX` / `*_MAX` enum sentinels

- **Exact test:**
  `EnumSentinelNamesPreserveLegacyExhaustivenessRoleCaseSensitively` in
  `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`.
- **Source fixtures and sealed roles:** omitted exact `MAX` gives
  `SwitchInvalidValue`; omitted `Value_MAX` gives `SwitchInvalidValue`;
  omitted ordinary case-sensitive `Max` remains `Statement`. All rows have no
  source default and preserve authenticated Case facts.
- **Authentic RED:**
  `Saved/Tests/cta-s180-enum-sentinel-role-red/`
  `20260902_020144_553_62c03bff`.
- **Focused GREEN:** **1/1** at
  `Saved/Tests/cta-s180-enum-sentinel-role-green3/`
  `20260902_020602_133_f98a7e3a`.
- **Production rule:** Sema alone reads the enum child's bare Canonical name
  with exact case-sensitive `MAX` / `_MAX` matching. Bytecode and TypedASTJIT
  do not scan names or recompute exhaustiveness.

### `SwitchInvalidValue` Canonical Bytecode consumption

- **Exact test:**
  `PreparedExhaustiveScriptEnumSwitchRaisesVmExceptionForInvalidRawValue` in
  `AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp`.
- **Source fixture:** prepared script enum values `First=1`, `Second=2`,
  `Negative=-1`; a no-default Switch covers all three values.
- **Asserted sealed facts:** exactly one Switch, three authenticated Cases, no
  default and role `SwitchInvalidValue` before CodeGen.
- **Consumer/provenance:** `GeneratePreparedModule` must publish Canonical
  CodeGen with zero LEGACY compiler invocations. Raw value `1` finishes and
  returns `10`; raw value `0x13579bdf` raises the exact VM exception
  `Invalid enum value passed to switch`.
- **Authentic RED:** **0/1** at
  `Saved/Tests/cta-s180-switch-invalid-red/`
  `20260902_020805_191_81a88276`; the invalid row incorrectly finished with an
  empty exception.
- **Focused GREEN:** **1/1** at
  `Saved/Tests/cta-s180-switch-invalid-green/`
  `20260902_020922_550_f6a7fb3c`.
- **Production rule:** `EmitSwitch` accepts only `Statement` or
  `SwitchInvalidValue`, uses the authenticated role to select the unmatched
  edge, and emits a final-case jump around the synthetic throw. It performs no
  enum lookup, name scan or exhaustiveness analysis.

## Structured verifier closure

The retained forged-graph matrix covers:

- `RejectsBreakSkippedNearerLoop`, `RejectsContinueSkippedNearerLoop`, and
  `RejectsContinueTargetWrongKindAndNonAncestor`;
- `RejectsMissingBreakAndContinueTargetsBeforePublication` and
  `RejectsMissingAndMismatchedCaseTargets`;
- `RejectsDuplicateCaseAndDefaultNotLast` plus normalized-domain duplicates;
- targetless/invalid Fallthrough outside a Switch, to a non-next Case, and in
  invalid structural positions;
- repeated child IDs under the same Block/Switch as duplicate structural
  incoming edges;
- malformed If/For/Foreach phase counts and phase kinds;
- transfer nodes with forbidden expression/declaration/child payloads;
- fail-closed Seal/publication for every malformed category.

These tests assert stable verifier categories/details and publication
rejection. Dump text is diagnostic output only.

## Final current-source owner gates

Every result below was read from its `Summary.json`; all have process exit 0,
zero failures and zero skips.

| Owner | Result | Evidence directory |
|---|---:|---|
| Compiler CanonicalAST SemaAuthority | **566/566 PASS** | `Saved/Tests/cta-s180-task56-sema-final/20260902_021032_602_3f97eabe` |
| Cache ASTBodySidecar | **27/27 PASS** | `Saved/Tests/cta-s180-task56-sidecar-final/20260902_021206_221_019c02ca` |
| Frontend CanonicalAST Verifier | **74/74 PASS** | `Saved/Tests/cta-s180-task56-verifier-final/20260902_021239_130_7e1dd324` |
| Frontend CanonicalAST | **203/203 PASS** | `Saved/Tests/cta-s180-task56-frontend-final/20260902_021312_849_8f16d3ef` |
| Compiler CanonicalAST ProductionCodeGen | **234/234 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.ProductionCodeGen/20260902_021452_516_46db9769` |
| Compiler CanonicalAST Semantics | **16/16 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Compiler.CanonicalAST.Semantics/20260902_022051_620_c2762489` |
| Module CanonicalAST Snapshot | **13/13 PASS** | `Saved/Tests/Angelscript.TestModule.AngelScriptSDK.Module.CanonicalAST.Snapshot/20260902_022125_208_97a6b66d` |

The ProductionCodeGen gate contains the invalid-enum VM oracle. Two existing
ScriptCorpus tests took approximately 95 and 89 seconds but completed
successfully; they are verification cost, not a correctness blocker or skip.

## Independent review and closure decision

Three read-only reviews independently inspected cross-enum recovery,
case-sensitive enum sentinels and the `SwitchInvalidValue` consumer. The final
post-repair review found no correctness blocker and agreed that the seven
current owner gates were the remaining closure condition. Optional future
hardening (for example, a forged contradictory default plus invalid-value role)
does not recompute Sema policy in a backend and is not a Task 5.6 blocker.

Task 5.6 is therefore closed. Formal OpenSpec progress moves from **110/136
= 80.9%** to **111/136 = 81.6%**. The broader lifetime, TypedASTJIT,
Bytecode/install, default-cutover and final All-suite rows remain independently
open.
