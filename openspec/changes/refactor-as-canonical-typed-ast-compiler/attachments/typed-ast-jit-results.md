# Section 7 TypedASTJIT gate notes

Canonical remains non-default. Production TypedASTJIT still prefers function-owned HIR when `VerifiedTypedHIR` is present so existing fixtures keep their native surface; sealed AST is used when HIR is absent.

## 7.1–7.6

| Gate | Result |
| --- | --- |
| `Tools\RunBuild.ps1 -Label canonical-ast-staticjit` | exit 0 |
| `Angelscript.TestModule.StaticJIT.TypedASTJIT.CanonicalASTMigration` | 7/7 |
| `Angelscript.TestModule.HotReload.CanonicalAST` | 5/5 |
| `Angelscript.TestModule.StaticJIT.ProjectGeneration.Engine` | 30/30 |

Adapter coverage: sealed AST eligibility without bytecode/HIR, frozen 31 fallback reasons, construct → `UnsupportedLifetime`, scalar emit determinism, standalone call → `UnsupportedCall`, Hot Reload lease A remains traversable after B publishes.

## 7.7

Full prefix `Angelscript.TestModule.StaticJIT` after golden LF restore and HIR-preference:

- Report: `D:\as-cta\Saved\Tests\canonical-ast-staticjit\20260821_041753_325_d5707409`
- **416/416** passed, 0 failed, 0 skipped

The three AOT/bridge golden failures were Windows `core.autocrlf` CRLF rewrites of `AngelscriptTestJIT/Generated/**`. `.gitattributes` now pins those goldens to `eol=lf`. No fallback became an unsafe direct call.

## 7.8

TypedASTJIT backend no longer calls `GetTypedSemanticFunction()`. Identity uses `VerifyTypedSemanticFunction(*Function.VerifiedTypedHIR)` when HIR is present, otherwise sealed AST. Snapshot capture still reads HIR as the remaining compiler oracle until section 10.

| Gate | Result |
| --- | --- |
| `Tools\RunBuild.ps1 -Label canonical-ast-worktree -NoXGE` | `FinalExitCode 0` (`20260821_043501_467_7c1b634a`, target up to date) |
| `Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT" -Label canonical-ast-staticjit` | **416/416** (`20260821_043518_306_34b6cc77`) |
| `TypedASTBackendRejectsReuseForeignEngineAndDetachedHIR` | 1/1 |

## Production wiring

- Parser Sema attaches only for `asAST_RETAIN_SNAPSHOT` or canonical pipeline.
- Module adopts the builder AST and publishes it on retain.
- Snapshot copies sealed AST + function decl id next to HIR.
- Backend/eligibility/call-closure/emit/deps accept sealed AST when HIR is missing.
