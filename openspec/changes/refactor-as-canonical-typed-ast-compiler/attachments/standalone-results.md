# Section 11 Standalone results

Worktree: `D:\as-cta`

## Debug CTest (`-Suite Standalone`, label `canonical-ast-standalone`)

- Command: `Tools\RunTestSuite.ps1 -Suite Standalone -LabelPrefix canonical-ast-standalone -TimeoutMs 600000`
- Result: **21/21 PASS**, 0 failed
- New CTest: `AngelscriptStandalone.CanonicalAST` (discard/retain, public V1, deterministic dump, CompileFunction snapshot, no dual/LLVM)
- Architecture CTest now requires canonical fork sources, no `llvm-project` / `clangAST` / `LLVM::` CMake link, and the CanonicalAST CTest target

This Debug count is independent of the previous `19/19` baseline: CanonicalAST is an added test, not a replacement for UE Automation numbers.

## Release CTest (`-Suite StandaloneRelease`, label `canonical-ast-standalone-release`)

- Command: `Tools\RunTestSuite.ps1 -Suite StandaloneRelease -LabelPrefix canonical-ast-standalone-release -TimeoutMs 1200000`
- Result: **21/21 PASS**, 0 failed
- Debug and Release are configurations of the same 21 CTests, not additive counts.
