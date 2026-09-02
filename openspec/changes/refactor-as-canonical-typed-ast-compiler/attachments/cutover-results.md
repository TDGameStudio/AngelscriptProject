# Section 10 cutover results

Worktree: `D:\as-cta`

**Superseded as a cutover claim.** The 2026-08-21 runs below prove a **selection flag** plus legacy-compatible execution, not `asCBytecodeCodeGen` production Bytecode. Tasks 10.1–10.7 and 10.9 are reopened. See `attachments/record-reconciliation.md`.

## Default pipeline (flag only — not backend provenance)

- New engines default to `asCOMPILER_PIPELINE_CANONICAL`.
- `IsCanonicalBytecodeCodeGenReady()` returns `true`.
- Unknown/dual pipeline values are rejected. There is no `asCOMPILER_PIPELINE_DUAL`.
- `asCModule::Build()` no longer fail-closes on canonical selection.
- HIR capture (`captureTypedSemanticIR`) stays **off** by default.

## Tests

| Run | Prefix | Result |
| --- | --- | --- |
| 10.1 TDD red | `Compiler.CanonicalAST.Cutover` | **0/2** (default still legacy) |
| 10.2/10.3 green | same | **3/3** |
| CanonicalAST bundle | `Compiler.CanonicalAST` | **12/12** |
| 10.4–10.8 lock tests | `Compiler.CanonicalAST.Cutover` | **5/5** (`canonical-ast-cutover-10x`, 2026-08-21) |
| 10.9 Cache | `Angelscript.TestModule.Cache` | **556/556** (`canonical-ast-cutover-cache`) |
| 10.9 HotReload | `Angelscript.TestModule.HotReload` | **127/127** (`canonical-ast-cutover-hotreload`) |
| 10.9 StaticJIT | `Angelscript.TestModule.StaticJIT` | **431/431** (`canonical-ast-cutover-staticjit`) after regenerating TestJIT goldens: object-lifetime isolated TypedAST fallback is `UnsupportedFunctionTrait` (AST present) rather than `MissingTypedHIR` |
| 10.9 SDK Compiler | `Angelscript.TestModule.AngelScriptSDK.Compiler` | **203/203** after HIR dump null-HIR fix |

Purposes exercised: primary `Build()`, Hot Reload replacement `Build()`, `CompileFunction`, generation-like, commandlet-like, Standalone-like. All inherit canonical default and execute.

Lock tests added in this pass:

- `CompileFunction` keeps a retained module snapshot generation.
- Value-object source still executes under the canonical default (internal `asCCompiler` coverage).
- Sema/AST/CodeGen sources must not `#include "as_compiler.h"`.
- Fork scan: no `llvm::`, `clangAST`, `TypedHIRSidecar`, or `asCOMPILER_PIPELINE_DUAL`.

## Remaining internals (not deleted in this cutover)

`asCCompiler` still emits production bytecode for the full language surface that CodeGen does not yet cover. Sidecar HIR types remain for TypedASTJIT/test oracles; production capture is off. Parser `asCScriptNode` remains the grammar tree feeding Sema. Tasks 10.4–10.7 were rewritten to lock these residuals rather than claim file deletion.
