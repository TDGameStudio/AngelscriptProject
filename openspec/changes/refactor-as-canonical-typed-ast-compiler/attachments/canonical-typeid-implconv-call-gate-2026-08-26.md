# Gate card: type-identifier + `opImplConv` + extra exact argument（2026-08-26）

- **OpenSpec task(s):** `0.2`, `5.3`, `13.2`, `13.6`
- **Source fixture:** `Create(CObj, 1)` where `CObj` rewrites to
  `const THost __StaticType_CObj` (VALUE, optionally `asOBJ_TEMPLATE`) and
  `THost` has `CClass opImplConv() const`; callee is `void Create(CClass, int)`.
- **Canonical fact:** sealed Call `Create` is resolved; arg0 is CONVERSION to
  `CClass` whose inner DeclRef is `__StaticType_CObj`; arg1 is the integer
  literal. No host type names (`UClass` / `TSubclassOf`) appear in Sema.
- **AST test:** `AngelscriptNativeCanonicalASTSemaTypeIdImplConvCallTests.cpp`
  / `TypeIdentifierValueOpImplConvMakesTwoArgCallViable`
- **AST-red:** `Saved/Tests/cta-typeid-implconv-ast-red/20260826_201929_558_8c4adbbe` (test asserted forward-formal children; dump already showed reverse-formal `Create` + `opImplConv`)
- **AST-green:** `Saved/Tests/cta-typeid-implconv-ast-3/20260826_202314_612_f04d86f1` **2/2**; UE type-id `cta-literal-asset-codegen/20260826_203802_252_58d0bf43` `CreateLiteralAssetTypeIdentifierSealsResolvedCall` PASS
- **CodeGen/provenance:** native Production StaticTypeIdentifier still green; UE `GetLiteral()` now publishes Canonical staged CodeGen (no unresolved-callee)
- **Lifecycle:** re-probe `ProjectGeneration.Engine` after this card
- **CompileModules AST-red:** `D:\as-cta\Saved\Tests\cta-s1-literal-asset-sema\20260826_215604_851_e53a4adb` and `cta-s1-literal-asset-sema-green2\20260826_220359_054_434df064` — `CreateLiteralAssetTypeIdentifierSealsResolvedCall` FAIL with `unresolved-callee:__CreateLiteralAsset nargs=2 hits=1 params=UClass,FString arg0=TSubclassOf<UObject> implConv=1 rank0=-1`. Direct `Module::Build` already PASS. Isolated Parser+Sema interned `UClass opImplConv`; CompileModules interned the zero-arg `UObject opImplConv` first and treated name+arity as identity.
- **CompileModules AST-green:** `D:\as-cta\Saved\Tests\cta-s1-literal-asset-sema-green3\20260826_220522_941_25b931ba` **2/2 PASS**. `InternNativeMethods` now distinguishes zero-arg conversion overloads by return type so both `UClass` and `UObject` `opImplConv` intern. No host-type-name ranking.
- **Remaining boundary:** Cache HardValue freeze (`FoldedGlobal…`) is S2. Generation `LiteralAssetRolesUseAuthoritativePostInitPairs` no longer reports `unresolved-callee:__CreateLiteralAsset`; it now fails on generated `__Init_PrimaryTypedAsset` / `__Init_SecondaryTypedAsset` (`hits=0`). That is a later unresolved-call slice, not this type-id/`opImplConv` card. Matching Generate Provider (F1/F5) and module generation transaction (F3/F4) are not this card.
