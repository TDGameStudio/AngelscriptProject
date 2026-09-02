# Gate card: S5 statement/control targets and phases（2026-08-26）

- **OpenSpec task(s):** `5.5`, `5.6`
- **Source fixture:** one sealed `Entry` owns if/else, do-while, while+continue, for with switch (fallthrough, continue-to-for, break-to-switch, break-to-for).
- **Canonical fact:** Clang-shaped named phases (`If.then/else`, `While/DoWhile/Switch.cond`, `For.init/body/incr`) and structured targets (`Continue`→loop, `Break`→switch or loop, `Fallthrough`→next case). For increment is an ExprStmt whose range is the increment, not the whole `for`.
- **AST test:** `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` / `ControlTargetsAndNamedPhasesSealTogetherOnCompileSealPath`
- **AST-red:** `Saved/Tests/cta-s5-sema-ctrl-red/20260826_230221_344_35453502` — 0/1. If/While/DoWhile/For/Switch nodes existed, but dump used `expr=` for While/DoWhile/Switch and lacked named `cond=`.
- **AST-green:** `Saved/Tests/cta-s5-sema-ctrl-green/20260826_231322_198_d86fd579` — 1/1. Dump now names `If then=/else=`, `While/DoWhile/Switch cond=`, `For init=/body=/incr=`. Continue skips Switch and targets While and For; Break hits Switch and For; Fallthrough targets the next Case; default is last Case with no expr.
- **CodeGen/provenance:** Sema/dump only this slice. Do not check `5.5`/`5.6` (backends still rerun Sema; no HIR cutover).
- **Lifecycle:** none.
- **Remaining boundary:** For increment ExprStmt source-range vs the whole `for` is still unproven (parser/Sema span). S6 is next (named materialize/cleanup phases; `try/catch` stays rejected).
