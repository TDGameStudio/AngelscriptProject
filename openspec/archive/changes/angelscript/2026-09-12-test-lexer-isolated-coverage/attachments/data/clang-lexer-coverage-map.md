# Clang 22.1.8 lexer coverage map for the isolated AngelScript tokenizer

Captured: 2026-09-12

## Fixed source

The repository's sparse `Reference/llvm-project` checkout does not materialize `clang/unittests/Lex`. Per `Reference/README.md`, this inspection used the local release archive at `D:/LLVM/llvm-project-22.1.8.src`.

- Version: 22.1.8 from `cmake/Modules/LLVMVersion.cmake`.
- Release identity: `llvmorg-22.1.8`; the unpacked directory has no `.git`, so no commit hash is claimed.
- Archive SHA-256 recorded by the inspection: `922F1817A0DF7B1489272D18134EE0087A8B068828F87AC63B9861B1A9965888`.
- `clang/unittests/Lex/LexerTest.cpp` SHA-256: `36C0AA8BEA6198295CC5F35E526F5C0AE4D834BE1617429E739710592DCB2A92`.
- `clang/unittests/Lex/LexHLSLRootSignatureTest.cpp` SHA-256: `F06BC002CC10FDB9EDFB76459EDC7B7FF1895DB7C1A420DC8F542BC52B61AC88`.

The historical draft finding `attachments/drafts/findings/clang-lexer-tests.md` says 12 C++ files. Direct `CMakeLists.txt` inspection establishes 11; the historical attachment remains immutable and this file is current evidence.

## Inventory

| File/group | Tests | Actual boundary |
|---|---:|---|
| `LexerTest.cpp` | 29 | Mixed Lexer, Preprocessor, SourceManager, macro location, raw utility, and preamble tests |
| `LexHLSLRootSignatureTest.cpp` | 4 | Small pull lexer: numbers, all token spellings, case policy, and peek |
| Other nine C++ files | 110 | Dependency scanning, header search/map, modules, PP callbacks/records, and allocation |
| Total | 143 | 11 C++ files; directory name does not imply 143 isolated scanner tests |

`LexerTest.cpp` further divides into 11 macro source-text/provenance tests, three macro/split-token/char-range tests, ten raw Lexer/navigation/utility tests, four Preprocessor/MacroArgs bookkeeping tests, and one preamble test. Its common `CheckLex` helper actually drives `Preprocessor::LexTokensUntilEOF`; it is not a raw-tokenizer fixture.

## Transferable coverage

| Clang shape | AngelScript state before this replan | Current disposition |
|---|---|---|
| Token range recovers authored source spelling | Tokens have source ranges, but current `TokenContractIsSourceReferentialAndDeclarative` hand-constructs one token and never slices actual captured source | Add exact keyword/identifier/literal/punctuation source slices in Contracts; every SpelledKinds row also compares its slice |
| Pull to terminal state and avoid buffer-tail over-read | Ordinary EOF and one malformed repeated EOF exist; no empty source, comment exactly at EOF, or dangling escape row | Add empty/pure-trivia stable EOF, line comment at EOF, and terminal string escape; helper records one separate repeated EOF |
| Raw and normal lexing agree on lexical projection | RetainTrivia and RawDirective compare only token count | Compare complete kind/range/flag projections and diagnostics; directive meaning stays downstream |
| Small-language `.def` walk | Plan already walks 107 non-empty AS spellings | Retain walk plus independent 115-row digest; this is stronger than expected kinds generated from the same `.def` |
| Case policy is explicit | Canonical spelling positives exist, but no casing mutations | Add `class/Class/CLASS`, `Cast/cast`, and `UPROPERTY/UProperty/uproperty` matrix |
| Valid encoding is distinct from lexical category | Malformed UTF-8 and policy-disabled Unicode are planned | Add U+00A2 under AllowUnicode as valid UTF-8, invalid identifier start, `UnexpectedCharacter [0,2)` |

No Clang peek API is added. The durable lexing spec keeps tokenizer lookahead consumer-owned.

## AngelScript-specific defect found during comparison

AngelScript 2.38's `sdk/angelscript/source/as_tokenizer.cpp:183-194` explicitly classifies `EF BB BF` as a three-byte whitespace token. Clang also accepts leading UTF-8 BOM in `clang/test/Lexer/minimize_source_to_dependency_directives_utf8bom.c`, but that case is secondary because it passes through dependency preprocessing.

The live reconstructed `frontend/Lexer/as_tokenizer.cpp` has no BOM branch. Under default AsciiOnly it decodes U+FEFF and produces:

```text
Invalid [0,3) StartOfLine|ContainsUnicode
EOF     [3,3)
diagnostic: UnicodeIdentifierDisallowed [0,3)
```

Task 1.3 now owns the grouped RED and a minimal product repair. Accepted post-repair rows are:

```text
RetainTrivia, EF BB BF
  Whitespace [0,3) StartOfLine
  EOF        [3,3) StartOfLine|LeadingSpace
  repeated EOF [3,3)
  diagnostics: none

SkipTrivia, EF BB BF + class
  KwClass    [3,8) StartOfLine|LeadingSpace
  EOF        [8,8)
  repeated EOF [8,8)
  diagnostics: none
```

## Explicit exclusions

- Macro expansion/spelling locations, token paste/stringize, MacroArgs, callbacks, headers, modules, dependency minimization, and preamble belong to Preprocessor/source/tooling layers.
- `SplitToken(>>)` is parser simulation. AngelScript lexer maximal-munch remains `ShiftRight`; nested generic interpretation stays downstream.
- `findNextToken`, `findPreviousToken`, and HLSL peek are consumer/tooling buffering, not core forward-only tokenization.
- C/C++ backslash-newline, trigraph, and translation-phase line rules do not define AngelScript string or newline behavior.
- CR-only start-of-line policy, ordinary unterminated-string newline ownership, three/four-byte Unicode identifier categories, and invalid bytes inside comments/strings require separate product decisions. This Change does not freeze current incidental behavior.

## Resulting method shape

```text
Contracts       18 methods  // 17 migrated + empty/pure-trivia stable EOF; exact source slices and repeated EOF
SpelledKinds     4 methods  // 107 round trips, 115-row digest, maximal munch, case-sensitive negatives
Recovery         9 methods  // malformed/recovery/state/buffer edges/BOM
```

The final focused prefix therefore contains 31 methods without importing Clang's Preprocessor and tooling surface.

