# Frontend lexer — implementation, pipeline, tests

Inspected 2026-09-12 on primary workspace `D:\Workspace\AngelscriptProject`.
Product lexer is the reconstructed frontend, not the quarantined Legacy `as_tokenizer.cpp`.

Spec: `openspec/specs/angelscript/language/frontend/lexing/spec.md`.
Knowledge: `lexing/knowledges/clang-lexer-hot-path.md`.

No line-coverage instrumentation was run. Coverage below is **contract + token-set inventory**, not llvm-cov / OpenCppCoverage.

---

## 1. What it is

`asCTokenizer` is a **pull, source-referential, engine-independent** scanner:

- Input: frozen UTF-8 bytes in `asCSourceSnapshot` → `asCSourceManager` → bounded `asCCharacterStream`.
- Policy: copy of `asSLexOptions` (Unicode identifiers + trivia mode). **Not** `asCScriptEngine::ep`.
- Output: one `asCToken` per `Lex(OutToken)`. Token stores kind, flags, half-open byte range, and (for names) a pointer into the session `asCIdentifierTable`.
- Spelling stays in the snapshot. Ordinary tokens do not allocate their text.
- Diagnostics go into a `lexer` fragment; the caller must `FlushDiagnostics()`.

It does **not** parse, preprocess, or validate numeric/string literals. `#` is just `Hash`. A line starting with `#` becomes a directive only in `asCPreprocessor`.

### 1.1 `asSLexOptions` — only two knobs

Defined in `frontend/as_frontend_options.h`. Immutable after construction (`const` members, copy yes, assign no). Default constructor is `AsciiOnly` + `SkipTrivia` (`asSLexOptions{}`).

```
asSLexOptions(UnicodeIdentifierPolicy, TriviaMode)
├─ UnicodeIdentifierPolicy     asEUnicodeIdentifierPolicy
│   ├─ AsciiOnly               // default; byte >= 0x80 is not an identifier
│   └─ AllowUnicode            // valid UTF-8 ident start/continue → Identifier
└─ TriviaMode                  asETriviaMode
    ├─ SkipTrivia              // default; Lex() swallows ws + comments
    ├─ RetainTrivia            // return Whitespace / LineComment / BlockComment
    └─ RawDirective            // enum exists; Lex() treats it as RetainTrivia
```

Nothing else: no engine pointer, no keyword set, no numeric radix policy, no string-escape policy, no `#` mode. Those are not lex options.

Who picks what:

| Caller | Unicode | Trivia |
|---|---|---|
| `asSLexOptions{}` / most `LexerTests` | AsciiOnly | SkipTrivia |
| `asCBuilder` Lexed | AsciiOnly | RetainTrivia |
| PP / Sema test helpers | AsciiOnly (or test AllowUnicode) | RetainTrivia |
| Binding declaration parse | AsciiOnly | SkipTrivia |

```
asCTokenizer
├─ [member] asCSourceManager SourceManager     // snapshot view; tokens point back here
├─ [member] asCCharacterStream Stream          // cursor over one file range
├─ [member] asSLexOptions Options              // frozen; no assignment
├─ [member] asCIdentifierTable& IdentifierTable
├─ [member] asCDiagnosticsEngine* + fragment   // flush once
└─ [state] bAtStartOfLine / bHasLeadingSpace   // next token flags
```

```
asCToken  (trivially copyable, tests require sizeof <= 64)
+00  Kind          asETokenKind   // from as_token_kinds.def (115 kinds + Count)
+02  Flags         asETokenFlags  // SOL / LeadingSpace / Unterminated / ContainsUnicode
+03  LiteralFlags  uint8          // unused in the scanner today
+04  Reserved      uint8
+08  Range         asCSourceRange // half-open UTF-8 bytes, file id
+..  Identifier* | RawPayload     // interned name, else unused
```

---

## 2. Files

| Role | Path |
|---|---|
| API | `angelscript/frontend/as_tokenizer.h` |
| Scan | `angelscript/frontend/as_frontend_tokenizer.cpp` |
| Token + helpers | `as_token.h`, `as_token_kinds.def` |
| Cursor | `as_character_stream.h` |
| Options | `as_frontend_options.h` (`asSLexOptions`) |
| Intern / keywords | `as_identifier_table.h/.cpp` |
| Snapshot / range | `as_source_snapshot.h`, `as_source_manager.h` |
| Diagnostics | `as_diagnostics.h`, `asELexDiagnosticID` in tokenizer header |
| Product pull-all | `angelscript/as_builder_frontend.cpp` stage `Lexed` |
| Binding decls | `as_binding_declaration.cpp` |
| Legacy (dormant) | `Legacy/angelscript/source/as_tokenizer.cpp` — different class API |

`as_token_kinds.def` is the single X-macro list: 8 structural kinds, **53 keywords**, **54 punctuation** (115 `AS_TOKEN` rows). Keywords include `Cast` (capital C), `delegate` / `event`, and the six `UCLASS`…`UMETA` spellings. `import` / `from` / `asset` / `UDELEGATE` are **not** keywords.

Each row is `AS_TOKEN(Name, Spelling, Keyword, Trivia)`. `as_token.h` includes the file five times with different `AS_TOKEN` macros to emit the enum, debug name, TCHAR/ANSI spelling, `asIsKeyword`, and `asIsTrivia`. Identifier intern uses the keyword spellings; `LexPunctuation` uses the longest non-keyword, non-trivia spelling. Empty spelling means “not matched as text” (Invalid, EOF, trivia, Identifier, literals).

---

## 3. Compile pipeline (where lex sits)

Builder stages are a one-way ladder. Lex is the first real work after `SourceReady`.

```
─────────────  asCBuilder::RunStage  ─────────────

SourceReady              frozen asCSourceSnapshot                 // files + UTF-8 bytes
      │
      ▼
Lexed                    asCTokenizer pull-all per file           // RawTokens + RetainTrivia
      │                  asSLexOptions(AsciiOnly, RetainTrivia)   // production Builder is ASCII-only
      ▼
Preprocessed             asCPreprocessor::Process(RawTokens)      // #if routing; no re-lex
      │                  Hash + StartOfLine => directive
      ▼
DeclarationsCollected    session CollectSource(ActiveTokens)
      │                  asCParser copies non-trivia tokens
      ▼
… Sema / AST / ModuleDefinitionSet / emit …
```

The tokenizer is **forward-only**. Lookahead and the retained stream are caller arrays (`RawTokens`, `ActiveTokens`). That matches the spec: full-stream retention is a Builder/PP cost, not the `Lex` contract.

```
asCBuilder::RunStage(Lexed)
└─ for each snapshot file
    ├─ asCTokenizer(Manager, whole-file range, AsciiOnly+RetainTrivia, State.Identifiers, Diag)
    ├─ loop Lex(Token) → Input.RawTokens                    // until EndOfFile or Lex false
    └─ FlushDiagnostics()

asCBuilder::RunStage(Preprocessed)
└─ Preprocessor.Process(RawTokens)
    ├─ Hash && StartOfLine  →  directive line
    └─ else if active && !trivia  →  ActiveTokens

asCParser::Collect(DirectiveProcessResult)
└─ copy ActiveTokens, drop trivia and EOF
    └─ ParseDeclaration() …
```

Other product callers (same `Lex` loop, different options):

| Caller | Options | Why |
|---|---|---|
| `asCBuilder` Lexed | AsciiOnly + **RetainTrivia** | PP needs `#` + `StartOfLine`; comments/ws stay in `RawTokens` |
| `FFrontendSessionRun` (test helper) | caller Unicode + RetainTrivia | same shape as Builder, then Process + CollectSource |
| `asCBindingDeclarationParser` | **defaults**: AsciiOnly + **SkipTrivia** | short host declaration strings |
| Isolated `LexerTests` | per-case | unit, no PP |

`RawDirective` exists on `asETriviaMode` but **`Lex` only special-cases `SkipTrivia`**. `RawDirective` currently behaves like `RetainTrivia`.

---

## 4. One `Lex` pull

```
asCTokenizer::Lex(OutToken)
  │
  ▼
[ Stream valid? ] ── No ──▶ return false                    // TryCreate failed
  │ Yes
  ▼
[ at end? ] ── Yes ──▶ EndOfFile (empty range), return true // repeatable
  │ No
  ▼
first byte
├─ space / tab / CR / LF
│   └─ LexWhitespace                         // SkipTrivia → loop; else return
├─ '/' and next is '/' or '*'
│   └─ LexComment                            // unterminated block → flag + diag
├─ ASCII ident start [A-Za-z_]
│   └─ LexIdentifier → IdentifierTable.Intern → Kind from entry
├─ byte >= 0x80
│   └─ LexUnicodeOrInvalid                   // policy / UTF-8 / ident start
├─ digit, or '.' + digit
│   └─ LexNumber                             // greedy; no radix/value check
├─ '"' or '\''
│   └─ LexString                             // """ / ''' heredoc; else escapes + no newline
├─ LexPunctuation                            // longest spelling, skip keywords/trivia
└─ else EmitInvalid (NUL or UnexpectedCharacter)
```

**Whitespace:** one token covering the whole run. `\n` sets `bAtStartOfLine`. Any ws sets `bHasLeadingSpace`. Line comments **do not consume** the following newline, so SOL is usually restored by the next whitespace token.

**Identifiers / keywords:** intern UTF-8 spelling; `ClassifyTokenKind` walks keyword rows in the `.def`. Same spelling in one table → same `asCIdentifierInfo*`. Six `U*` names also get `asEReflectionSpelling`; Lexer does not build Attr.

**Numbers:** consume digits, ASCII letters, `.`, `_`, and `+/-` only after a non-based `e`/`E`. `0x1e+2` stays `0x1e` then `+` `2`. `123abc` and `0b102` are still **one** `NumericLiteral`. No `LiteralFlags` fill-in.

**Strings:** `"""` / `'''` (same quote ×3) run to the closer, including newlines and quotes; no escape processing. Ordinary `"…"` / `'…'` stop at unescaped quote or CR/LF; `\` skips the next byte.

**Punctuation:** maximal munch over non-keyword spellings. `array<array<int>>` ends as `ShiftRight` (`>>`), not two `Greater`. That is tested and is the current contract.

**Recovery:** every non-EOF token has a non-empty range. Bad UTF-8 consumes **1** byte. Repeated `Lex` at EOF returns EOF again. Hang-prevention is the main invariant.

Diagnostics (`asELexDiagnosticID`):

| ID | When |
|---|---|
| InvalidUtf8 | decode failed |
| UnicodeIdentifierDisallowed | non-ASCII ident under AsciiOnly |
| EmbeddedNul | `0` byte |
| UnexpectedCharacter | `$` and similar, or Unicode that is not an ident start |
| UnterminatedString | quote not closed |
| UnterminatedBlockComment | `/*` to EOF |

---

## 5. Tests that exist

### 5.1 Dedicated unit — `NewVersion/NativeEngine/LexerTests.cpp`

One `TEST_CLASS` `Lexer`, TestDir `Angelscript.UnitTest.NativeEngine`. Public names are `Angelscript.UnitTest.NativeEngine.Lexer.<Method>` (**16** methods + 5 `static_assert`s). You can already prefix-filter that class; TestDir itself is not nested. See `findings/test-prefix.md`. Helpers `FLexerSource` / `CaptureTokenProjection` / `MeasureLexer` live in a file-level anonymous namespace (conflicts with the draft’s later “no anonymous namespace in AS tests” rule; not moved yet).

| Method | What it proves |
|---|---|
| `FrozenOptionsAreValueOwned` | options copyable, not engine-sourced |
| `CharacterStreamUsesValidatedSnapshotRange` | bounded cursor; invalid range rejected |
| `TokenContractIsSourceReferentialAndDeclarative` | kind name / spelling / keyword / trivia / SOL on a hand-built token |
| `PullLexerClassifiesKeywordsReflectionSpellingsLiteralsAndPunctuation` | `class` / `UPROPERTY` / `42` / `"AS"` / `@` |
| `OnlySixOuterAnnotationsAndCallableIntroducersAreKeywords` | 6 `U*` + `delegate` `event`; `UDELEGATE` `import` `from`… stay Identifier |
| `LeadingDotExponentAndRadixNumbersRetainWholeTokens` | `.5` `1.` `1e+2f` `0x` `0b` `0o` `0d` + greedy junk lengths |
| `HexadecimalEDigitDoesNotAbsorbAdjacentAddition` | `0x1e+2` |
| `RepeatedIdentifiersReuseOneSessionEntry` | one interned `Thing` |
| `HeredocIsOneLiteralAcrossNewlinesAndEmbeddedQuotes` | `"""…"""` |
| `PostfixAndNestedGenericPunctuationPreserveMaximalMunch` | `.` `:` `++` `>>` |
| `IndependentSessionsProduceIdenticalTokenProjection` | two tables, same dump; SkipTrivia default hides Whitespace |
| `UnicodePolicyIsFrozenPerTokenizer` | `πValue` Allow vs Ascii + diag 1002 |
| `MalformedBytesAlwaysAdvanceAndDiagnoseOnce` | `FF 00 $ "x` → 4 diags, EOF sticky |
| `UnterminatedBlockCommentConsumesToEnd` | `/*` + Unterminated + diag |
| `TriviaModesPreserveNonTriviaRanges` | Skip vs Retain vs RawDirective (`#` range stable; Raw count == Retain) |
| `IndependentParallelSessionsRemainDeterministic` | 16× ParallelFor |
| `RepresentativeCorpusRecordsColdAndWarmEvidence` | 256× sample; intern allocations freeze on warm; **logs** times, no threshold |

### 5.2 Adjacent live tests (use the lexer, do not specify it)

| File | Role |
|---|---|
| `SourceDiagnosticsTests.cpp` | snapshot / half-open UTF-8 ranges / diag emit — **not** `asCTokenizer` |
| `NativeEngineTestSupport.h` `FFrontendSessionRun` | lex + PP + session (Sema tests) |
| `Builder/BuilderStageTests.cpp` | `RunStage(Lexed)` is **stage-order**, not token kinds |
| `Preprocessor/*` | consume already-lexed tokens (`#` + SOL) |
| `Definitions/DefinitionConsumerTests.cpp`, `Declarations/DeclarationSemanticTests.cpp`, `Reflection/AngelscriptFrontendReflectionDescriptorTests.cpp`, `Api/CanonicalNamespaceTests.cpp` | construct `asCTokenizer` as a fixture |

### 5.3 Not live

| Tree | Why it does not count |
|---|---|
| `AngelscriptTest/Legacy/AngelScriptSDK/Frontend/AngelscriptNativeTokenizer*.cpp` | old `GetToken` / `IsKeyWord` / `ParseToken` API; `WITH_ANGELSCRIPT_UNITTESTS=0` + `.ubtignore` |
| `AngelscriptEditor/Legacy/Tests/LearningTraceTokenizerTests.cpp` | baseline vs old tokenizer; Editor Legacy |

Prefix `Angelscript.UnitTest.NativeEngine.Lexer` already selects this class. Kind-by-kind completeness: `findings/lexer-tests.md`.

---

## 6. Coverage

### 6.1 Against the current lexing spec — strong

| Spec requirement | Live proof |
|---|---|
| Frozen options, no engine | `static_assert` + `FrozenOptionsAreValueOwned` + Unicode pair |
| Pull + source-referential | almost every method; `TokenContract…` |
| Session intern | `RepeatedIdentifiersReuseOneSessionEntry` + warm corpus |
| Six U* + delegate/event keywords | `OnlySixOuter…` |
| Malformed always advances | `MalformedBytes…` + unterminated comment |
| Trivia modes, non-trivia ranges invariant | `TriviaModes…` |
| Determinism / thread | identical projection + ParallelFor |
| Corpus measurement | `RepresentativeCorpus…` (evidence log only) |

All six `asELexDiagnosticID` values can fire from the two recovery tests plus Unicode (1001–1006 appear as a set, not each asserted by ID except UnicodeIdentifierDisallowed).

### 6.2 Against the token table — sparse

115 kinds. Dedicated lexer tests **name** roughly:

- keywords: `class`, six `U*`, `delegate`, `event` (plus `int` only as a number-adjacent ident in other strings)
- punctuation: `{` `@` `+` `.` `;` `:` `++` `>>` `#`
- structural: Identifier, NumericLiteral, StringLiteral, Whitespace (indirect), LineComment, BlockComment, Invalid, EndOfFile

Unnamed in lexer tests: most language keywords (`if` `foreach` `Cast` `mixin` `fallthrough` …), almost all operators (`**` `>>>` `<<=` `&&` `::` …), single-quoted strings, `'''` heredoc, empty file, invalid tokenizer object, `FlushDiagnostics` twice, Unicode **continue** after ASCII start, overlong/surrogate UTF-8, line-comment-without-newline at EOF.

`LexNumber` / `LexString` are **scan**, not validate. `0b102` and `1e+` staying one token is tested as length, not as “later Sema must reject”.

### 6.3 Product-path gaps (not missing unit tests, but different options)

- **Builder always `AsciiOnly` + `RetainTrivia`.** Unicode-ident tests do not exercise the compile ladder.
- **`RawDirective` is a label**, not a third scan. Spec text says behavior “follows that explicit mode”; implementation + test treat it as Retain.
- **`asCToken::LiteralFlags` is dead.**
- **`>>` maximal munch** is the documented lexer behavior; generic close-angle splitting is Parser’s problem, not covered here.
- Line coverage %: **unknown**. No coverage job in this research pass.

---

## 7. How this relates to the test-framework draft

Q6 already named **Lex** as a NativeEngine unit. Q7 named `LexTestHelper.h`. Today that helper does **not** exist: `FLexerSource` and the projection dump are private to `LexerTests.cpp`. Sema/Builder tests each re-open a tokenizer loop.

`AS_TEST_SOURCE` is **not** used. Lexer fixtures go through `FSourceInput::FromText` / raw `uint8` into a snapshot — the same layout-insensitive path the draft is replacing for handwritten AS.

Legacy tokenizer tests are reference only; they must not be re-enabled as the new Lex suite.

---

## Conclusions

1. Current AS lex is Clang-shaped: immutable buffer, pull `Lex`, compact token, session intern, frozen options. Implementation is small (`as_frontend_tokenizer.cpp` ~500 lines) and already wired as Builder stage `Lexed`.
2. Preprocessor and Parser **do not re-scan source**. They walk token arrays. `#` + `StartOfLine` is the only directive hook.
3. Live Lex tests are **one file, 16 methods**. They cover the **spec contract** (policy, intern, recovery, trivia skip/retain, determinism, corpus log) well.
4. They do **not** cover the token vocabulary. Most keywords and operators have no named assertion. There is no table-driven kind matrix and no measured line-coverage number.
5. Production Builder lex is **ASCII + retain trivia**. `RawDirective` is unimplemented as a distinct mode.

## Open

- Whether Lex tests should grow a **keyword/punctuation matrix** (or stay contract-only) is a later design choice; this finding does not pick it.
- `LexTestHelper.h` vs keeping helpers inside `LexerTests.cpp` waits on the TestFramework tree (already settled in principle, not applied).
- Next NativeEngine unit in the same inventory style is **Preprocessor** (`asCPreprocessor` on token arrays), if you want the same treatment.
