# Section 4 declaration/type Sema results

Worktree: `D:\as-cta`  
Canonical pipeline remains non-default.

| Gate | Result |
| --- | --- |
| `RunBuild.ps1 -Label canonical-ast-decl-sema -NoXGE` | FinalExitCode 0 |
| `...Frontend.CanonicalAST` | 18/18 PASS |
| `...AngelScriptSDK.Frontend` | 187/187 PASS |
| `...AngelScriptSDK.Compiler` | 195/195 PASS |
| `...AngelScriptSDK.Module` | 56/56 PASS |
| `...AngelScriptSDK.TypeSystem` (`canonical-ast-type-sema`) | 45/45 PASS |

Root-cause fixes that unblocked 4.1/4.2: `snParameterList` is a flat TYPE/TYPEMOD/IDENTIFIER sequence (not per-param wrappers); function bodies are only superficially parsed unless Sema is attached, so `return 7` is now fully parsed into `IntegerLiteral`.
