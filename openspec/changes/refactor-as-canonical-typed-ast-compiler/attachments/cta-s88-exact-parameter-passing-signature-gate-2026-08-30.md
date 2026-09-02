# CTA-S88 exact parameter passing and script ABI gate — 2026-08-30

## Outcome

CTA-S88 closes the reviewed current-module, automatic-import, native-method
and native-behaviour projection defects where Canonical source identity and
Runtime ABI identity were compared through incomplete type/reference tests.

The repaired contract deliberately separates two domains:

```text
script source formal
  -> Canonical source type + source passing
  -> NormalizeScriptParameterABI only when matching a script Runtime shell

registered native/system formal
  -> exact Runtime datatype + exact inOutFlags
  -> no script ABI normalization
```

Script projections now recover the source-facing type with
`asCRuntimeTypeBridge::FromScriptParameterABI`. Current-module and automatic
import CodeGen then lower that source type back through
`NormalizeScriptParameterABI` before exact Runtime-shell authentication.
Native projections instead preserve the registered direct ABI and take
`in`, `out`, and `inout` exclusively from the exact Runtime `inOutFlags`
entry. `asCDataType::IsReference()` is no longer used to infer direction.

This slice also fixes an independently exposed template-factory defect: a
script Runtime template factory stub has already removed the hidden TypeInfo
formal and must not have its first authored formal skipped a second time.

## Production changes

### Script Runtime shell to Canonical source identity

`as_sema_expr.cpp` adds `CanonicalScriptParameterType`, which:

1. reads the exact Runtime formal ordinal;
2. reads the exact `inOutFlags` value, including `asTM_NONE`;
3. calls `FromScriptParameterABI`;
4. returns the source-facing Canonical `asCQualType`.

`HasMatchingExternalScriptFunction`, current-module projection and automatic
import projection use this helper and compare complete return and formal
types plus qualifiers. The relation is still joined by the sealed
`ParamDecl.formalIndex`; structural child position is not reintroduced.

### Script Canonical source identity to Runtime shell ABI

`as_bytecode_codegen.cpp` now applies the inverse script-shell
authentication at both production lookup boundaries:

- `FindAutomaticImportedScriptGlobalFunction`;
- `FindCurrentModuleScriptGlobalFunction`.

For each exact formal the resolver now:

1. resolves the source-facing Canonical datatype;
2. derives passing from Canonical qualifiers;
3. calls `NormalizeScriptParameterABI`;
4. compares the full `asCDataType` with `operator==`;
5. compares the exact Runtime passing flag, including `asTM_NONE`.

Return types use full datatype equality but do not receive parameter ABI
normalization.

### Native method and behaviour direction

Native method and behaviour matching/materialization use
`CanonicalRuntimeParameterType` with the exact Runtime `inOutFlags` entry.
This fixes the prior rule that effectively treated every Runtime reference as
an input reference and therefore projected `int&out` as `int&inout`.

Native behaviour matching receives `sourceParameterStart` explicitly and
joins Canonical formal `p` to Runtime formal `sourceParameterStart + p`.
Hidden factory/template prefix formals remain outside the source constructor
signature.

### Template factory hidden-formal ownership

Generated script template-factory stubs already expose a Runtime parameter
vector with their leading TypeInfo formal stripped. The secondary
template-factory skip now applies only when `func->funcType != asFUNC_SCRIPT`.
Without this guard the first authored constructor/factory argument was also
removed, producing an empty projected signature.

## TDD evidence

### Current-module passing direction

- RED:
  `Saved/Tests/cta-s88-current-module-passing-red/20260830_111109_501_87fd8e08`
  — **0/1** as expected.
- GREEN:
  `Saved/Tests/cta-s88-current-module-passing-green/20260830_111238_643_87358ca5`
  — **1/1 PASS**.
- Fixture: `CurrentModuleProjectionDistinguishesParameterPassingMode`.

### Script value-parameter source ABI

- RED:
  `Saved/Tests/cta-s88-script-value-abi-red/20260830_111814_745_63299b2a`
  — **0/1**; Runtime `const T&inout` normalization leaked into Canonical
  source identity.
- GREEN:
  `Saved/Tests/cta-s88-script-value-abi-green/20260830_111934_616_c55b4247`
  — **1/1 PASS**.
- Fixture: `CurrentModuleProjectionRestoresSourceValueParameterABI`.

### Native method exact OUT direction

- RED:
  `Saved/Tests/cta-s88-native-method-passing-red/20260830_112335_440_9008ad6c`
  — **0/1**; the old projection produced INOUT.
- The method fixture then passed in
  `Saved/Tests/cta-s88-native-passing-green/20260830_112621_669_57f791d5`.
- Final grouped GREEN is recorded below.
- Fixture: `NativeMethodProjectionPreservesExactOutDirection`.

### Native behaviour and template factory visible formal

After the fixture was corrected to model the real hidden-TypeInfo prefix, the
production path exposed a second skip of the first authored formal:

- semantic RED despite the historical label containing `green-r3`:
  `Saved/Tests/cta-s88-native-behaviour-passing-green-r3/20260830_113005_861_f5f02cf9`
  — projected visible formal count was zero;
- GREEN:
  `Saved/Tests/cta-s88-template-factory-visible-formal-green/20260830_113126_950_38ce0207`
  — **1/1 PASS**.
- Fixture: `NativeBehaviourProjectionDistinguishesParameterPassingMode`.

The RED label is retained as immutable run evidence; this attachment records
its actual result rather than interpreting the label as success.

### Production CodeGen script ABI lookup

The corrected automatic-import fixture produced a genuine no-normalization
RED in:

- `Saved/Tests/cta-s88-script-runtime-abi-codegen-red-r2/20260830_113752_193_a279c64c`.

The independent primitive current-module lookup was then reverted to the old
resolver for a deterministic RED:

- `Saved/Tests/cta-s88-current-module-primitive-abi-red/20260830_114227_368_5072f818`
  — **0/1**.

Restoring both production normalizers yielded:

- `Saved/Tests/cta-s88-script-runtime-abi-final-green/20260830_114319_324_3c554e47`
  — **2/2 PASS**;
- final build:
  `Saved/Build/cta-s88-script-runtime-abi-final-green-build/20260830_114305_474_a68b234e`
  — PASS.

Fixtures:

- `CanonicalCompileFunctionBindsCurrentModuleValueParameterABI`;
- `CanonicalAutomaticImportBindsScriptValueParameterABI`.

## Fresh grouped and regression gates

| Gate | Result | Evidence |
| --- | ---: | --- |
| Four CTA-S88 SemaAuthority fixtures | **4/4 PASS**, 0 failed, 0 skipped | `Saved/Tests/cta-s88-sema-passing-group-green/20260830_114854_803_a1680b91` |
| ProductionCodeGen complete prefix | **154/154 PASS**, 0 failed, 0 skipped | `Saved/Tests/cta-s88-production-codegen-full-green/20260830_114930_428_ce04b08c` |
| Canonical CodeGen transaction/rollback | **21/21 PASS**, 0 failed, 0 skipped | `Saved/Tests/cta-s88-codegen-transaction-green/20260830_115010_928_945eb6ec` |
| Compiler CanonicalAST + TypedASTJIT + NativeBridge | **719/719 PASS**, 0 failed, 0 skipped | `Saved/Tests/cta-s88-compiler-typedjit-nativebridge-full-green/20260830_115058_047_3596996e` |

The broad run emitted the existing environment HTTP connectivity warning in
provider tests, but the Automation report and process both completed with
exit code 0.

## Test-authoring and diagnostic runs excluded from semantic evidence

The following runs helped establish a valid production fixture but are not
credited as RED evidence for the repaired semantic contract:

1. The first native-behaviour test did not compile because the private
   `asCRuntimeTypeBridge` definition was incomplete at the test site. Adding
   the maintained-fork private header fixed the fixture, not production.
2. A direct test call to `InternNativeMethods` failed to link because that
   private Runtime-DLL symbol is not exported. The fixture was changed to
   enter the method through a real Sema call action.
3. A pre-created Canonical class was treated as authored and therefore
   correctly suppressed native projection. The fixture now lets production
   create the native class view.
4. `array<T> f(int&in)` contains only the hidden TypeInfo formal. The valid
   fixture uses hidden TypeInfo plus one authored visible formal.
5. Initial value-object CodeGen fixtures failed at unrelated
   `by-value-copy-constructor-unavailable` and `DANGLING_ID construct-decl`
   boundaries. The final fixtures forward an existing parameter or use a
   primitive by-value call, isolating the resolver behavior.

These exclusions prevent test harness mistakes from being counted as proof
that production behavior was previously wrong.

## Residual exact-signature backlog

CTA-S88 does not close every Runtime resolver. A current read-only audit found
the following registered-native CodeGen scanners still use coarse datatype
tests:

- `FindRegisteredGlobalFunction`;
- `FindExactRegisteredMethod`;
- `FindExactRegisteredConstructor`;
- `FindExactRegisteredListFactory`.

The confirmed reachable case is a registered native method pair:

```text
int Read()
int Read() const
```

Canonical Sema and stable keys distinguish the pair, and mutable-receiver
ranking selects the non-const declaration. `FindExactRegisteredMethod` does
not currently compare `IsReadOnly`, so both Runtime methods match and CodeGen
fails closed with an ambiguous binding. The next TDD slice must compare full
datatypes, exact passing including NONE, exact vector lengths and method
readonly while preserving inherited/template candidates and constructor/list
factory hidden-prefix rules.

## Non-invertible source ABI boundary

Runtime shell data alone cannot always reconstruct source formal identity:

```text
source T                    -> Runtime const T&inout
source const T&inout        -> Runtime const T&inout
```

`FromScriptParameterABI` necessarily guesses `T` for this Runtime shape. A
single explicitly authored `const T&inout` current-module or automatic-import
function can therefore be reprojected as by-value even though same-name
overloads of these two forms cannot coexist.

The complete repair must carry producer-authored structured source formal
metadata or retain an exact association to the sealed Canonical declaration.
It must not parse stable-key strings or infer source semantics from the live
Runtime shell.

## Non-claims

- The registered-native resolver backlog above remains open.
- Runtime `defaultArgs` ownership/projection remains a separate production
  defect and is recorded in the sibling default-argument audit.
- TypedASTJIT immutable Runtime type-binding authentication remains open and
  is recorded in its sibling audit.
- Tasks 7.2, 7.4 and 7.5 remain unchecked for complete family-wide breadth.
- Product default remains LEGACY; CTA-S88 does not authorize default cutover.
- Standalone remains excluded and was not changed or tested.
- The native AngelScript parser AST remains retained for syntax/recovery,
  explicit LEGACY, differential/reference work and future syntax support.
- HIR remains physically absent and was not recreated.

