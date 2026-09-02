# TypedASTJIT production HIR-read removal gate — 2026-08-23

## Scope

This is the AST-first gate for the production-input portion of Tasks `7.2`
and `7.8`, and a prerequisite for `10.5`. It does not delete the maintained
HIR types or their direct unit-test oracles. It removes HIR as a production
TypedASTJIT eligibility/dependency/body-selection authority only after the
same-generation sealed canonical AST and exact Decl identity are available.

## Contract

- **Source fixture:** a sealed canonical global `int Run()` plus a deliberately
  contradictory captured HIR header claiming an instance invocation and
  native-object receiver.
- **Canonical fact:** production shape comes from the exact canonical Decl and
  current Runtime function signature. A captured HIR pointer cannot change
  invocation or receiver classification.
- **Body authority:** `FunctionHasTypedASTJITCanonicalBody` requires a sealed
  AST plus a valid exact declaration. HIR-only input is a safe native fallback,
  not a TypedASTJIT body.
- **Legacy oracle boundary:** direct HIR analyzer/emitter/eligibility unit tests
  remain available while later compiler/cache/dump migration still needs
  comparison. Production graph routing must not call them.
- **Failure behavior:** missing AST or missing exact Decl identity fails closed;
  it must never reconstruct AST, inspect Bytecode for meaning, or bind the first
  same-name declaration.

## TDD

- **Test source:**
  `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/TypedASTJIT/CanonicalASTMigration/AngelscriptCanonicalASTJITAdapterTests.cpp`.
- **RED methods:**
  `ProductionEligibilityInputIgnoresCapturedHirShape` and
  `ProductionCanonicalBodyRejectsHirOnlyInput`.
- **RED evidence:** pending.
- **GREEN evidence:** pending.

## Intended production flow

```text
sealed AST lease + exact DeclId + Runtime signature
                    |
                    v
        canonical TypedASTJIT shape / eligibility
                    |
                    v
        canonical dependency analysis + emission

captured HIR --------------------------> test/oracle only
HIR-only production view --------------> safe VM/Bytecode fallback
```

## Non-claims

This gate does not finish canonical call closure (`7.4`), lifetime/exception/
provider publication (`7.5`), delete all HIR implementation and tests (`10.5`),
or make CANONICAL the default (`10.2`).

## Gate card: script enum functional conversion keeps semantic identity and emits scalar ABI storage

- **OpenSpec task(s):** `7.2`, `7.4`, `7.8`, `10.5`, `13.2`.
- **Source fixture:** `enum EMode { Zero, One }` and
  `int ConvertMode(int RawMode) { EMode Mode = EMode(RawMode); return RawMode; }`.
- **Canonical fact:** after `Parser -> Sema -> Seal`, `EMode(RawMode)` is one
  explicit `Conversion<int -> EMode>` whose destination is the script enum
  canonical type. It is not an unresolved `CALL`, and the local declaration
  remains enum-typed rather than being relabelled as a value object or plain
  integer in the AST.
- **AST test:**
  `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp`
  — `EnumFunctionalCastIsCanonicalConversionNotUnresolvedCall`. The test
  compiles real source with retained canonical AST and inspects the sealed
  internal context through the production module-retention path.
- **AST-red:** focused `0/1`, because the functional cast remained an
  unresolved CALL and could not seal a dumpable graph. Evidence:
  `Saved/Tests/cta_enum_functional_cast_red/20260824_020742_676_1524b699/RunMetadata.json`.
- **AST-green:** focused `1/1`; lexical script enum lookup now interns
  `asAST_TYPE_ENUM`, and the functional cast is the exact conversion asserted
  above. Evidence:
  `Saved/Tests/cta_enum_functional_cast_type_authority/20260824_021455_287_c4c554f0/RunMetadata.json`.
- **CodeGen/provenance:** RED at the real TestJIT generation boundary. Call
  closure now passes (`Functions=1 Calls=0`), then canonical emission rejects
  the enum local with `Local declaration type is outside the reviewed scalar
  set`. Evidence:
  `Saved/StaticJIT/TestJIT/Commandlet/cta_hir_removal_provider_regen_v2_02_generate/20260824_021542_126_a1a48d81/Commandlet.log`.
  The focused permanent regression
  `SourceEnumLocalEmitsScalarAbiStorageWithoutCppEnumDependency` was then
  observed RED `0/1` with the same local-declaration failure:
  `Saved/Tests/cta_enum_abi_emitter_red/20260824_022218_225_0fffe827/RunMetadata.json`.
  It is now GREEN `1/1`: the emitter retains `EMode` in the sealed AST while
  spelling its current ABI carrier as `int8`, emits
  `WrapNarrow<int8>` for the `int -> EMode` conversion, and emits no script-only
  `EMode` C++ dependency. Evidence:
  `Saved/Tests/cta_enum_abi_emitter_green/20260824_022715_841_00678d93/RunMetadata.json`.
- **Lifecycle:** rerun the official `Tools\\RunStaticJITTests.ps1 -Mode
  Generate` flow, rebuild the generated TestJIT provider, and run the focused
  AOT/full StaticJIT groups after the focused emitter gate is green.
- **Focused regression:** owning
  `StaticJIT.TypedASTJIT.CanonicalASTMigration` group is `13/13 PASS`:
  `Saved/Tests/cta_enum_abi_emitter_group_green/20260824_022800_017_7d42579a/RunMetadata.json`.
  NoXGE build is green:
  `Saved/Build/cta_enum_abi_emitter_green_build_v2/20260824_022656_246_9200dd57/RunMetadata.json`.
  The official Provider generation/lifecycle stage remains pending below.
- **Remaining boundary:** this card covers by-value script enums whose current
  maintained-fork AngelScript ABI storage is one signed byte. It does not authorize
  handles/references, arbitrary named value objects, C++ enum symbol spelling,
  or a wider native eligibility surface.
