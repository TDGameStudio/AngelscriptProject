# Isolated lexer tests: std-owned run, independent oracles, bounded recovery

disposition: promoted
promoted_to: angelscript/language/frontend/lexing/knowledges/isolated-lexer-test-oracles.md

## Reusable Insight

An isolated pull-lexer test surface is most useful when one small object owns source bytes and one captured run, while scenario methods own expected meaning. Standard-library strings and containers make byte-exact cases, generated rows, and result views independent of a host framework; host/product adapters remain explicit and narrow.

```text
FStringView -> FTCHARToUTF8 ----┐
                                ├-> std::string bytes -> one stable run -> std::vector captures
std::string_view exact bytes ---┘                         ├-> Contracts      // authored source slices + sticky EOF
                                                          ├-> SpelledKinds  // generated stimulus + fixed digest
                                                          └-> Recovery      // bounded inputs + authored oracles
```

Generated stimulus is not automatically an independent oracle. When both a lexer and its test input walk consume the same token-definition table, deletion or retargeting can self-confirm. Keep the dynamic round trip for breadth, but add a literal digest or another independently maintained acceptance anchor. Likewise, a negative generator emits inputs only; expected tokens and diagnostics stay outside it.

Terminal behavior needs two distinct observations when EOF is sticky: retain one first EOF in the semantic token stream, then record a separately named repeated-EOF probe. This avoids duplicating EOF in ordinary expectations while retaining post-terminal stability and an exact pull bound.

## Evidence

- Live `LexerTests.cpp` isolates `asCTokenizer` but duplicates snapshot/token capture, aggregates malformed diagnostics, and explicitly pulls EOF a second time.
- `asETokenKind` and `asGetTokenSpellingAnsi` are generated from the same `as_token_kinds.def` rows that punctuation and keyword recognition consume.
- The inspected table has 115 rows, 107 non-empty spellings, and accepted FNV-1a `0xa912c3f84387564e` under the recorded serialization.
- Clang 22.1.8's closest reusable patterns are exact source spelling, bounded terminal pulls, raw/normal lexical parity, all-token coverage for a small `.def` language, and an explicit case policy; macro/source/tooling tests are downstream concerns.
- The current tokenizer emits malformed UTF-8 one byte at a time, distinguishes valid nonidentifier Unicode at another branch, and lacks the official AngelScript 2.38 three-byte BOM whitespace path.

## Boundaries

- This is not a parser, preprocessor, Sema, Bindings, TestCode, source-catalog, or dynamic-registration design.
- `FNativeEngineTokenizerTest` may own Lexer-specific malformed recipes, but generic source identity/history, reusable generators, typed rows, and artifacts remain with the unified-framework Change.
- CQTest macros stay in `TEST_METHOD` bodies. Each global scenario class privately aliases only the `LexerTest` types it references, restores `public:` before method registration, and leaves the surrounding Unity translation unit unpolluted; the helper accepts the public asserter object, reports one contextual mismatch, and returns a consumed boolean.
- `std::string` owns bytes and UTF-8 descriptions, but `FStringView`, snapshot views, product types, and `Fail(FString)` remain explicit integration boundaries.
- A digest freezes an accepted sequence; it does not explain a desired future vocabulary change. Intentional table changes update the literal alongside reviewed product expectations.
- Do not infer macro provenance, parser token splitting, CR-only newlines, non-BMP identifier policy, or string/newline recovery from Clang's C/C++ tests.

## Application

For another isolated frontend stage, separate input ownership, execution/capture, and expectation checking. If generated data shares implementation metadata, add a literal accepted anchor. Use explicit byte strings for invalid encoding or embedded NUL, keep generated rows bounded until a common generator contract exists, and name any post-terminal observation separately from the primary stream.

## Sources

- `attachments/data/clang-lexer-coverage-map.md`
- `attachments/drafts/findings/lexer-tests.md`
- `attachments/drafts/findings/lexer-kind-matrix-plan.md`
- `attachments/talks/talk-20260912-133353-unity-safe-class-aliases.md`
- `Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_tokenizer.cpp`
- `Reference/angelscript-v2.38.0/sdk/angelscript/source/as_tokenizer.cpp`
