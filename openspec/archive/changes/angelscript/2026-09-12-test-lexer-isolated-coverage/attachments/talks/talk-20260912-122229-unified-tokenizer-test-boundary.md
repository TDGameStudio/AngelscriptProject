# Unified tokenizer-test boundary

## Context

The user asked whether the isolated lexer slice should expose one reusable test class that owns code, input, captured output, helper checks, and bounded negative generation, while a later Change still owns the project-wide TestCode center. The creation plan had only `FLexerSource` plus free `CheckLex` helpers and used the token spelling table as both stimulus and oracle.

## Evidence

- `FSourceInput::FromText` is the inspected UE-text-to-UTF-8 boundary; `asCSourceSnapshot::AddFile` already accepts and copies `TConstArrayView<uint8>` with an explicit length.
- Current reconstructed NativeEngine tests use UE string/byte views rather than `std::string`; invalid UTF-8 and embedded NUL are byte fixtures, not text strings.
- `asCTokenizer` is pull-based, freezes `asSLexOptions` by value, writes identifiers through a caller-owned table, and flushes structured diagnostics into `asCDiagnosticsEngine`.
- CQTest's assertion macro is bound to the test object. A reusable helper can instead receive `FNoDiscardAsserter&`, emit contextual failure details, and return a consumed boolean.
- `angelscript/refactor-testing-unified-framework` already owns generic source identities/history, catalogs, typed data rows, result artifacts, and reusable generators.

## Settled Decision

Use `AngelscriptNativeEngineTest::FNativeEngineTokenizerTest` as a lexer-only vertical fixture. It owns UTF-8 bytes, the frozen snapshot, identifier table, tokens, and collected diagnostics; exposes `FromText`, `FromUtf8Bytes`, `WithOptions`, captured-result views, `Describe`, `CheckKinds`, and `Check`; and provides a deterministic malformed-UTF-8 input recipe.

```text
FStringView ── FromText ───────┐
                               ├─ owned UTF-8 bytes ─ one tokenizer run ─ tokens + diagnostics
byte view ─── FromUtf8Bytes ───┘                                  ├─ CheckKinds // concise contracts
                                                                  ├─ Check      // ranges/flags/diagnostics
                                                                  └─ Describe   // actionable failures
```

The negative generator emits inputs and stable names only. Test methods independently state token and diagnostic expectations. The accepted spelling vocabulary gets a fixed digest because the dynamic round trip and the tokenizer share the same `.def` table.

## Consequences

- Do not add `std::string` or `std::string_view`: they add a third representation without improving UE text encoding or the explicit raw-byte boundary.
- Do not dynamically register generated rows. One static Recovery method iterates a bounded set and includes the row name and bytes in failure output.
- The helper remains under `TestFramework/NativeEngine`, while Automation registration stays in `NativeEngine/Lexer` scenario translation units.
- Later unified-framework work may adapt or replace the helper's source-copy internals, but it need not rewrite Lexer expectations or preserve a competing catalog/generator system.

## Flip Condition

Move the malformed recipe or source ownership into the common framework only after that framework's typed generator or frontend-source contract exists and can preserve byte-exact invalid input, stable row identity, one-run capture, and actionable failure rendering. Until then, local Lexer ownership is smaller and independently testable.

## Sources

- `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/NativeEngineTestSupport.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_source_snapshot.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_tokenizer.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/as_frontend_tokenizer.cpp`
- `openspec/changes/angelscript/refactor-testing-unified-framework/tasks.md`

