# Canonical string-literal Sema and CodeGen gate（2026-08-25）

## Scope

This AST-first gate advances Tasks `0.2`, `5.2`, `5.3`, `5.9`, `9.2`, `9.5`, `9.6`, `13.2`, and `13.6` for the next uniform failure exposed by the real StaticJIT generation source graph: `Throw("Executing unbound delegate.")` inside the preprocessor-generated delegate `Execute` method.

The preceding receiver card proves that `_Inner.IsBound()` reaches its exact native VALUE receiver without loading the 32-byte object. This card proves that a source string token becomes a Sema-owned semantic byte sequence and that Canonical CodeGen consumes those bytes through the registered Engine string factory. It does not authorize CodeGen to parse source spelling, and it does not make Cache V2 a cutover dependency.

## AST-first card

| Field | Evidence |
| --- | --- |
| Sema test source | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTSemaAuthorityTests.cpp` |
| Exact Sema method | `StringLiteralStoresDecodedBytesAndExactLength` |
| Sema source fixture | `Throw("line\\nmid\\0tail")` with an Engine-authoritative `FString` type and exact `Throw(const FString&in)` native declaration |
| Required sealed facts | exactly one `StringLiteral` argument; exact Engine `FString` QualType; exact resolved native callee; payload bytes are `line`, newline, `mid`, embedded NUL, `tail`; byte length is exactly 13 and is not derived with `strlen`; raw quotes and escape spelling are absent from the semantic payload |
| Persistence/public contract | `asCString` retains all bytes; the kind-discriminated `literalBits` field records string byte length for the existing public V1 view; sidecar encoding/decoding uses the stored length and preserves embedded NUL without an AST ABI layout change |
| CodeGen test source | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` |
| Exact CodeGen method | `PreparedStringLiteralUsesFactoryAndExactReferenceABI` |
| Runtime fixture | isolated registered POD value type used as the Engine string type, tracking `asIStringFactory`, and exact generic `int ObserveString(const FProdCanonicalString&in)` callback that queries the factory by the received object identity |
| CodeGen RED contract | sealed AST and exact callee assertions pass, then Canonical CodeGen fails closed on `StringLiteral`; neither `asCCompiler` nor HIR publishes the body |
| CodeGen GREEN contract | acquire the constant once from `engine->stringFactory` using the sealed decoded bytes and exact length; materialize only its pointer identity; pass that identity through the reference ABI to the exact `CALLSYS`; never construct/copy a fake string value and never inspect quote/escape syntax |
| Lifetime GREEN contract | the native observer sees all 13 bytes including the embedded NUL; the entry result proves the exact payload; temporary CodeGen acquisition is balanced after `AddReferences()` establishes the function-owned reference; module/function retirement releases the remaining reference exactly once |
| Broader regression | focused SemaAuthority, focused ProductionCodeGen, complete ProductionCodeGen, AST sidecar round-trip, CodeGen rollback, and real generation 32-test group |

## Root-cause evidence

- Receiver-fixed generation report: `Saved/Tests/cta-generation-after-value-receiver/20260825_040037_935_16e4bf64` — **12/32 PASS, 20/32 FAIL**.
- The prior 32-byte receiver read-width token is absent.
- Structured unsupported-expression diagnostic: `Saved/Tests/cta-generation-unsupported-expr-diagnostic/20260825_040506_694_af76b128`.
- Every source-compilation failure now reaches `kind=StringLiteral`, `type=const FString`, and literal spelling `"Executing unbound delegate."`.
- `asCSema::ActOnExprFromNode` currently passes the raw token returned by `NodeText` to `ActOnStringLiteral`, so the AST stores source spelling rather than decoded semantic bytes.
- `asCASTContext::SetLiteral` and sidecar `AppendBytes` currently use null-terminated text semantics even though `asCString` itself is length-aware.
- Canonical `EmitExpr` has no `StringLiteral` lowering. Legacy `asCCompiler` decodes first, calls `GetStringConstant(bytes, length)`, emits `PGA`, and keeps a temporary reference until the function has acquired its own bytecode reference.

## Design decision

The chosen boundary is Sema-authoritative and length-aware:

```text
raw source token
      |
      v
Canonical Sema decode (Engine scanner/string-encoding policy)
      |
      v
StringLiteral.literal = exact semantic bytes
StringLiteral.literalBits = exact byte length
      |
      +--> public view / dump / sidecar
      |
      v
Canonical CodeGen string-factory lease
      |
      v
PGA identity --> exact reference ABI --> resolved native/script call
```

The decoder belongs to the frontend/Sema layer. CodeGen receives no raw spelling and therefore cannot diverge from semantic escape, Unicode, multiline, or heredoc policy.

## Forbidden shortcuts

- Do not strip quotes or process escapes in `as_bytecode_codegen.cpp`.
- Do not call `strlen` for a semantic string payload.
- Do not encode an embedded NUL as two source characters in the sealed AST.
- Do not mark arbitrary string objects trivial-copyable or copy factory-owned object bytes.
- Do not locate `Throw`/`ObserveString` by name in CodeGen.
- Do not use `asCCompiler`, HIR, or a LEGACY fallback.
- Do not keep an unbalanced factory reference on successful, failed, or rolled-back generation.

## Evidence log

- AST-first RED: pending.
- Sema GREEN / CodeGen RED: pending.
- CodeGen/runtime GREEN: pending.
- Sidecar/public regression: pending.
- Real generation regression: pending.
