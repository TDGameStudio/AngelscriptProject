# Section 6 Cache V2 AST sidecar results

Worktree: `D:\as-cta`

| Gate | Result |
| --- | --- |
| `RunBuild.ps1 -Label canonical-ast-cache-v2 -NoXGE` | FinalExitCode 0 |
| `...Cache.ASTBodySidecar` | **6/6 PASS** (kind/version, retain restore, incremental reuse/rebuild, dependency closure, atomic commit, dump/HIR/old-schema miss) |
| `...HotReload.CanonicalAST` | **4/4 PASS** (leases + sidecar hash replacement) |
| `...Cache` (`canonical-ast-cache-v2`, TimeoutMs 1800000) | **555/555 PASS** failed=0 skipped=0 |

Canonical default remains off. FunctionBody VM bytes / `SaveByteCode` unchanged; `ASTBodySidecar` is a separate record kind.
