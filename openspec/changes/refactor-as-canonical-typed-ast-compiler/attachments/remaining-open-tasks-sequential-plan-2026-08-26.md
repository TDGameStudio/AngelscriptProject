# Remaining open tasks — sequential plan（2026-08-26）

Implementation workspace: `D:\as-cta`. Dual-repo: plugin first, then parent gitlink + OpenSpec.
Architecture reference: `attachments/llvm-ast-architecture.md` (Clang layering, not LLVM IR).
Do not check `10.2` / `10.5` / `10.6` / `12.4` until their gates are actually green.
Do not archive unless the user asks.

OpenSpec mechanical remainder: **41 unchecked** of 119. These are overlapping
acceptance umbrellas, not 41 independent features. Close them in the order
below. Each semantic slice still follows Gate 0: AST-red → AST-green →
CodeGen/provenance → lifecycle if crossed → focused regression.

## Clang mapping used for every remaining slice

```text
SourceManager + FileID     already landed (task 2.x / 13.10 residual audit)
Parser actions → Sema      remaining 4.x / 5.x / 13.2
ASTContext + QualType      landed; template instance keys still bite (TSubclassOf)
ImplicitCast / Materialize remaining conversion ranking + lifetime plans
CodeGenFunction(const Stmt*) remaining 9.x / 13.6
CFG derived later          not this change
```

## Sequence (do not skip)

### Wave S — Sema authority (unblocks everything else)

| Order | Tasks | Smallest remaining fact | Verify |
| ---: | --- | --- | --- |
| S1 | `5.3`, `13.2`, `13.6` | `__CreateLiteralAsset(Type, "Name")` seals a resolved Call; type-id rewrites to `__StaticType_<Type>` VALUE/TEMPLATE; `opImplConv` ranks to the REF formal; string/`FString` second arg is viable | focused Sema + Production prefixes, then `ProjectGeneration.Engine` |
| S2 | `5.3`, `9.5`, `13.6` | Cache V2 freeze keeps a HardValue row for folded globals (`FoldedGlobalKeepsStableHardValueDependencyThroughTypedASTEmission`) | generation Engine + Cache AST sidecar |
| S3 | `5.2`, `5.3` | remaining unresolved native/script calls in generation and SDK matrices become sealed Calls with conversions, not dummy ints | SemaAuthority + ProductionCodeGen + generation |
| S4 | `5.4` | property/index/mutation chains, short-circuit, conditional, compiler-generated values have explicit sequence/single-eval nodes | SemaAuthority + differential VM |
| S5 | `5.5`, `5.6` | remaining statement/control targets and phases (not just foreach) | SemaAuthority stmt dump |
| S6 | `5.7`, `5.8` | materialize/cleanup plans for value objects, handles, globals, transfer; keep `try/catch` rejected | SemaAuthority + CodeGen cleanup |
| S7 | `5.9` | containers, delegates, lambdas, funcdefs, imports, generated accessors/list factories; no executable Unsupported node | ProductionCodeGen group + SDK language |
| S8 | `4.2`–`4.6` | declaration Sema is the production owner: signatures, defaults, mixins, lambdas, dependencies, shadow-mismatch oracle. Parser `asCScriptNode` remains recovery only | Frontend + SemaAuthority + mismatch tests |
| S9 | `13.2` close | no backend re-walks `asCScriptNode` for meaning; sealed dumps show overload/conversion/call/lifetime/control | SemaAuthority complete group |

S1–S3 generation compile tokens are closed (Engine 32/32). S4 AST-green: combined property/index OpaqueValue, Logical, Conditional, and Sema-owned default `40+1` (`canonical-sequence-single-eval-gate-2026-08-26.md`). Do not check `5.4`. S5 AST-green: named `cond=`/`then=`/`else=`/`init=`/`body=`/`incr=` plus structured Continue/Break/Fallthrough (`canonical-control-target-phase-gate-2026-08-26.md`). Do not check `5.5`/`5.6`. S6 AST-green: value temporary `literal=cleanup`, value return `literal=return`, handle is not `T::~T()` return cleanup, `try/catch` stays rejected (`canonical-lifetime-cleanup-phase-gate-2026-08-26.md`). Do not check `5.7`/`5.8`. S7 AST-green: compile-seal `array<int>` TEMPLATE, host funcdef local Conversion, capturing lambda, import, list factory (`canonical-container-funcdef-lambda-import-gate-2026-08-26.md`). Do not check `5.9`. S8 AST-green: mixin `origin=T`, mixin default `40+1`, distinct lambda keys, `T.bases`→`IProbe` (`canonical-declaration-sema-ownership-gate-2026-08-26.md`). Do not check `4.2`–`4.6`. Next is **S9** (no backend re-walk of `asCScriptNode`).

### Wave B — backends consume only the sealed graph

| Order | Tasks | Fact | Verify |
| ---: | --- | --- | --- |
| B1 | `9.1`, `9.5`, `13.6` | CodeGen accepts only sealed AST; full 9.5 object/container/delegate/lambda/exception/lifetime subset; detached artifact + rollback | ProductionCodeGen + transaction matrix |
| B2 | `9.6` | debug/coverage/timeout/safe-point/layout published as backend output | Debugger + Coverage prefixes |
| B3 | `9.7` | isolated differential over active Native SDK + Script corpus | Compiler/Runtime/Language prefixes |
| B4 | `7.2`, `7.4`, `7.5` | TypedASTJIT eligibility/calls/cleanup from Canonical visitors | StaticJIT TypedASTJIT |
| B5 | `7.8` | remove production `GetTypedSemanticFunction()` reads | StaticJIT prefix + build |

### Wave C — snapshot / SourceManager / adversarial protocol

| Order | Tasks | Fact | Verify |
| ---: | --- | --- | --- |
| C1 | `3.4` | every *production* source build owns AST through Bytecode CodeGen (LEGACY sidecar-only is not enough; this waits on cutover) | Module Snapshot + Cutover |
| C2 | `13.8`, `13.11` | candidate verify/seal then atomic replace; Acquire vs publish race; failed publish keeps last good generation; CodeGen failure mutates nothing | Snapshot + HotReload + adversarial tests |
| C3 | `13.10` | SourceManager coordinates through Lexer/Parser/Sema/diagnostics/backend; remap validates content identity | SourceManager + Frontend |

### Wave D — production selection, then default, then delete old path

| Order | Tasks | Fact | Verify |
| ---: | --- | --- | --- |
| D1 | `10.1`, `10.3`, `10.4`, `10.7` | every purpose selects Canonical; `CompileFunction` snapshot policy; production Bytecode is `asCBytecodeCodeGen`; no `dual` | Cutover matrix |
| D2 | `0.2`, `0.3` | every remaining card is green; full AST gate matrix recorded | listed prefixes in 0.3 |
| D3 | `10.2` | Canonical becomes default; LEGACY opt-out only | **after D2** |
| D4 | `10.5`, `10.6` | remove production HIR; `asCScriptNode` is not a semantic body | StaticJIT + Compiler |
| D5 | `10.9` | focused SDK/HotReload/StaticJIT + Cache V2 default-disabled | those prefixes |

### Wave E — docs and final verification

| Order | Tasks | Fact | Verify |
| ---: | --- | --- | --- |
| E1 | `11.4` | embedding-client migration notes | docs only |
| E2 | `12.2` | focused SDK/Cache/HotReload/StaticJIT/Debugger/Coverage counts | `RunTests.ps1` prefixes |
| E3 | `12.4`, `13.12` | All suite zero new failures; do not re-check section 10 from compatibility prefixes | `RunTestSuite.ps1 -Suite All` |

## Current execution pointer

**S1–S8 AST slices are green.** F2/F8 sidecar 16/16. Generation Engine after S3: **32/32**. S4 combined sequence/single-eval: `cta-s4-sema-seq-green/20260826_225544_107_2b448b8b` 1/1. S5 combined control targets/phases: `cta-s5-sema-ctrl-green/20260826_231322_198_d86fd579` 1/1. S6 combined lifetime: `cta-s6-sema-life-green/20260826_232620_384_120516ba` 1/1. S7 combined container/funcdef/lambda/import: `cta-s7-sema-bind-green/20260826_233941_438_6e1672aa` 1/1. S8 declaration Sema: `cta-s8-sema-decl-green/20260826_234950_571_b51db429` 1/1. Next is **S9**. S8 card: `canonical-declaration-sema-ownership-gate-2026-08-26.md`. Do not check `4.2`–`4.6` / `5.4`–`5.9`.

S1 evidence already in hand:

- `opImplConv` ranking is language-level (no `UClass` name special-case).
- Native `FHost` VALUE → `CClass` REF is Sema+CodeGen green.
- CompileModules `__CreateLiteralAsset(UObject, "Name")` now seals a resolved Call (`LiteralAssetSema` 2/2). Zero-arg conversion overloads intern by return type so `UClass opImplConv` is not dropped after `UObject opImplConv`.
- Generation Engine re-probe `cta-s1-generation-engine` **29/32**. `__CreateLiteralAsset` is gone from LiteralAssetRoles; remaining fails are `FoldedGlobal…` (S2), generated `__Init_*` (`hits=0`), and mutual-recursion unresolved callee.

S1's AST-first card is `attachments/canonical-typeid-implconv-call-gate-2026-08-26.md`.
