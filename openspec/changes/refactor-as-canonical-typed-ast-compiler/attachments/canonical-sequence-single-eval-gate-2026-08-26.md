# Gate card: S4 sequence / single-eval / short-circuit / conditional / generated default（2026-08-26）

- **OpenSpec task(s):** `5.4`
- **Source fixture:** one sealed `Entry` owns `Make().Value += 1`, `Make()[0] += 1`, `F(1) && G(2)`, `Flag ? F(3) : G(4)`, and `Add(Chosen)` where `Add(int, int Right = 40 + 1)`.
- **Canonical fact:** property and index mutations share one OpaqueValue receiver each; Logical/Conditional are named nodes; the omitted default is a Sema-owned typed Binary `40+1` (Clang `CXXDefaultArgExpr`), not `strtoull` of `defaultArg` text.
- **AST test:** `AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` / `SequenceSingleEvalShortCircuitConditionalAndGeneratedDefaultAreSealedTogether`
- **AST-red:** `Saved/Tests/cta-s4-sema-seq-red/20260826_225255_302_baaa1535` — 0/1. Property/index/Logical/Conditional already sealed; param `Right` had `default=40 + 1` text and no `inits`; `Add(Chosen)` filled `IntegerLiteral literal=default:40 + 1` via `strtoull`.
- **AST-green:** `Saved/Tests/cta-s4-sema-seq-green/20260826_225544_107_2b448b8b` — 1/1. Parser `sema` path uses `ParseAssignment` for defaults; Sema interns the typed expr onto param `inits`; call fill wraps it as a generated Conversion (Clang `CXXDefaultArgExpr`). Native/hidden `defaultArg` strings still `strtoull` only when `inits` is empty.
- **CodeGen/provenance:** call sites consume the sealed Conversion/Binary, not `atoi` of the same text. Do not check `5.4` until backends stop copying default text as an executable plan and isolated LEGACY/CANONICAL traces remain green.
- **Lifecycle:** none.
- **Remaining boundary:** `asCScriptFunction::defaultArgs` still stores presentation text for runtime `GetParam`; that is metadata, not Sema. S5 control targets/phases are AST-green; S6 is next.
