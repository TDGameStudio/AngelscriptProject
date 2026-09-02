# Gate card: same-section forward call to global `external_implicit_this`（2026-08-26）

- **OpenSpec task(s):** `5.2`, `5.3`, `13.2`
- **Source fixture:** `int Entry() { Helper(1); return 1; }` then `void Helper(int Value) external_implicit_this {}`. Generation `asset Name of Type` expands to `GetName()` calling `__Init_Name` before the `__Init_Name(...) external_implicit_this` declaration.
- **Canonical fact:** the later global function is a sealed FUNCTION decl; the earlier Call binds to it (`hits>=1`, resolved callee).
- **AST test:** `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` / `GlobalExternalImplicitThisFunctionIsVisibleToEarlierCall`
- **AST-red:** `Saved/Tests/cta-s3-sema-ext-impl-this/20260826_222719_105_f957d860` — `unresolved-callee:Helper nargs=1 hits=0`; Seal `r=-10`. Generation: `cta-s2-generation-engine` LiteralAssetRoles `__Init_PrimaryTypedAsset` / `__Init_SecondaryTypedAsset` `hits=0`.
- **AST-green:** `Saved/Tests/cta-s3-sema-ext-impl-this/20260826_224129_969_d9082c51` — 1/1. Parse-time ranking extras (` nargs=… hits=…`) made `ResolveDeferredCalls` miss the stale diagnostic (`Equals("unresolved-callee:Helper")`). Prefix-strip on successful bind; true misses keep the diagnostic. Diagnostics after parse: 0.
- **CodeGen/provenance:** generation Engine `Saved/Tests/cta-s3-generation-engine/20260826_224223_790_7f266b38` **32/32**. LiteralAssetRoles `__Init_*` and MutualRecursion bind.
- **Lifecycle:** generation Engine closed for S3; no Cache/HotReload boundary in this slice.
- **Remaining boundary:** none for this gate. Next sequential slice is S4 (property/index/mutation/short-circuit/conditional/single-eval).
