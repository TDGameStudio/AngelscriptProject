# Gate card: folded const global HardValue survives snapshot freeze（2026-08-26）

- **OpenSpec task(s):** `5.3`, `9.5`, `13.6`
- **Source fixture:** emit-module `const int TypedASTFoldedGlobal_65C28A = 7;` plus `ReadTypedASTFoldedGlobal_65C28A()` that returns that global.
- **Canonical fact:** sealed Decl `TypedASTFoldedGlobal_65C28A` has `hasConstantValue` and `constantValue==7`. Canonical prepared CodeGen publishes `asCGlobalProperty::isPureConstant` **before** function-body emission so `MarkDependency` captures `asBUILD_ARTIFACT_DEPENDENCY_HARD_VALUE`. Snapshot freeze retains a `HardValue` semantic-dependency row keyed to that global.
- **AST test:** `AngelscriptStaticJITGenerationEngineTests.cpp` / `FoldedGlobalKeepsStableHardValueDependencyThroughTypedASTEmission` (sealed DeclRef + `hasConstantValue`, then Cache/snapshot HardValue).
- **AST-red:** `Saved/Tests/cta-s1-generation-engine/20260826_220710_107_6e095254` — sealed constant is present; `At least one Cache hard-value row must survive snapshot freeze` because function emission ran before `CommitPreparedGlobals()` set `isPureConstant`.
- **AST-green:** `Saved/Tests/cta-s2-folded-global-hardvalue-green/20260826_221844_921_2601793c` **1/1 PASS**. Prepared CodeGen now sets `isPureConstant` before body emission and folds the DeclRef to `SetConst` (no `LDG`), so function-fact capture keeps a HardValue row and TypedASTJIT emits `FromCanonicalBits<int32>(UINT64_C(7))`.
- **CodeGen/provenance:** Canonical prepared CodeGen must mark HARD_VALUE on the reader function's artifactDependencies.
- **Lifecycle:** generation snapshot freeze copies that HardValue into `SemanticDependencies`.
- **Focused regression:** `Angelscript.TestModule.StaticJIT.ProjectGeneration.Engine`.
- **Remaining boundary:** `__Init_*` unresolved calls (LiteralAssetRoles) and mutual-recursion unresolved callee are not this card.
