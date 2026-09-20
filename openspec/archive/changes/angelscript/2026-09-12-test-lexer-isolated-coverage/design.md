# Isolated lexer test coverage

Approved design from `attachments/drafts/design.md`, revised by the applied tokenizer-boundary, standard-library/CQTest/Clang-gap, and Unity-safe alias replans. Talks under `attachments/talks/` record the layout, public-name, kind-matrix, TestCode-boundary, standard-library ownership, and class-alias decisions. `attachments/data/clang-lexer-coverage-map.md` is the current fixed-snapshot comparison.

## Context

The reconstructed pull lexer (`asCTokenizer`) is already isolated in `NewVersion/NativeEngine/LexerTests.cpp`: one `TEST_CLASS Lexer`, seventeen contract methods, public filter `Angelscript.UnitTest.NativeEngine.Lexer.*` through a flat TestDir, and helpers in a file-level anonymous namespace. About 26 of 115 `as_token_kinds.def` kinds are named. The planning-only Change `angelscript/refactor-testing-unified-framework` owns TestCode / `AS_TEST_SOURCE`, generic data generation, and the common frontend source/diagnostic fixture; it is not reopened here. The workspace already contains empty user-reserved `TestFramework/NativeEngine/NativeEngineTokenizerTest.h/.cpp` files, which supply the landing name for this lexer-only pilot without authorizing edits to sibling AST placeholders.

The creation-time kind walk was not an independent mutation oracle: it sourced text from `asGetTokenSpellingAnsi`, while `asCTokenizer::LexPunctuation` and keyword interning consume the same `.def` rows. A deletion disappears from the loop; a retarget can move both sides together. The current lexing spec also requires table-driven malformed-input recovery, while the old test asserts only an aggregate diagnostic count.

The user subsequently selected standard-library ownership for tokenizer-test data and collections. CQTest inspection proves that `TEST_CLASS_WITH_FLAGS` expands to a global `struct`; C++ rejects a namespace using-directive in that class body, but permits alias declarations such as `using FExpectedToken = LexerTest::FExpectedToken;`. A file-scope namespace import would compile, yet can pollute every later source fragment in an Unreal Unity translation unit. The final convention therefore keeps the CQTest class global, gives each class only its actually referenced private helper aliases, and restores `public:` before `TEST_METHOD` so registration members remain accessible.

Fixed inspection of LLVM/Clang 22.1.8 shows that `clang/unittests/Lex` contains 11 C++ files and 143 tests. `LexerTest.cpp` has 29 mixed Lexer/Preprocessor/SourceManager tests, the HLSL Root Signature pull lexer has four, and the remaining 110 mostly test PP/dependency/header/module behavior. The transferable gaps are exact source spelling through token ranges, empty and buffer-tail termination, lexical mode parity, and an explicit case policy. AngelScript's own 2.38 tokenizer also proves `EF BB BF` is whitespace; the reconstructed tokenizer currently routes it to a Unicode diagnostic.

## Goals / Non-Goals

**Goals:**

- Give lexer tests a durable home outside `NewVersion/`: one tokenizer-specific test class in `TestFramework/`, scenario TUs under `NativeEngine/Lexer/`.
- Replace the anonymous helper namespace with `namespace LexerTest`; keep scenario CQTest classes global and use only class-scoped `using X = LexerTest::X;` aliases.
- Make standard-library ownership the helper default while keeping UE/product types at necessary conversion and tokenizer boundaries.
- Nest TestDir so the public prefix is `Angelscript.UnitTest.NativeEngine.Lexer`.
- Keep all seventeen contract methods, retain their repeated-EOF assertion, add empty/pure-trivia EOF coverage, add an independently anchored spelled-kind matrix and case policy, and strengthen recovery/state boundaries.
- Prove leading UTF-8 BOM as whitespace with grouped RED/GREEN in task 1.3.
- Generate bounded negative rows without dynamic test registration and prove the slice with Harness `ue.test` on the Lexer prefix.

**Non-Goals:**

- Product tokenizer changes other than the BOM defect demonstrated by task 1.3 grouped RED.
- `FTestAST`, preprocessor, Sema, Bindings, or relocating the rest of `NewVersion/`.
- `FTestInputs` / `AS_TEST_SOURCE` / TestCode.
- Generic source catalogs, data-row registration, result artifacts, property/fuzz infrastructure, or a second common frontend fixture.
- Macro/source-provenance, token split/peek/navigation, preamble/header/module, or C/C++ translation-phase behavior copied from Clang.
- Freezing CR-only newlines, valid non-BMP identifier categories, malformed bytes inside comments/strings, or ordinary string/newline recovery before those policies are decided.
- Deciding the `SourceDiagnostics` public prefix or walking AST `.def` tables.

## Decisions

### Split layout and alias boundary

```text
AngelscriptTest/
├─ TestFramework/NativeEngine/
│  ├─ NativeEngineTokenizerTest.h
│  └─ NativeEngineTokenizerTest.cpp
│     └─ namespace LexerTest                    // helper types only; no Automation registration
└─ NativeEngine/Lexer/
   ├─ LexerContractsTests.cpp
   │  └─ global Contracts struct -> 3 private LexerTest aliases -> public TEST_METHODs
   ├─ LexerSpelledKindsTests.cpp
   │  └─ global SpelledKinds struct -> 1 private LexerTest alias -> public TEST_METHODs
   └─ LexerRecoveryTests.cpp
      └─ global Recovery struct -> 5 private LexerTest aliases -> public TEST_METHODs
```

Delete `NewVersion/NativeEngine/LexerTests.cpp` after the move. `#include "TestFramework/NativeEngine/NativeEngineTokenizerTest.h"` uses the module include root. Populate the existing empty tokenizer helper files; leave `1.h` and `NativeEngineASTTest.*` untouched.

The CQTest macro invocation remains at global scope inside the replacement compile gate. Its class body begins with a private alias set and then restores `public:` before any `TEST_METHOD`. `Contracts` aliases `FNativeEngineTokenizerTest`, `FExpectedToken`, and `FLexExpectation`; `SpelledKinds` aliases only `FNativeEngineTokenizerTest`; `Recovery` aliases `FNativeEngineTokenizerTest`, `FExpectedToken`, `FExpectedLexDiagnostic`, `FLexExpectation`, and `FMalformedUtf8Case`. These aliases shorten only their owning class and do not change the macro, class token, TestDir, Automation identity, or surrounding Unity translation unit.

```cpp
TEST_CLASS_WITH_FLAGS(Contracts, "Angelscript.UnitTest.NativeEngine.Lexer", ...)
{
private:
	using FNativeEngineTokenizerTest = LexerTest::FNativeEngineTokenizerTest;
	using FExpectedToken = LexerTest::FExpectedToken;
	using FLexExpectation = LexerTest::FLexExpectation;

public:
	TEST_METHOD(FrozenOptionsAreValueOwned)
	{
		// ...
	}
};
```

### Public identities

| Piece | Value |
|---|---|
| TestDir | `Angelscript.UnitTest.NativeEngine.Lexer` |
| Classes | `Contracts`, `SpelledKinds`, `Recovery` |
| Helper namespace | `LexerTest` |

### Standard-library tokenizer-test surface

```cpp
namespace LexerTest
{
	struct FExpectedToken
	{
		AS_NAMESPACE_QUALIFIER asETokenKind Kind;
		asUINT Begin;
		asUINT End;
		AS_NAMESPACE_QUALIFIER asETokenFlags RequiredFlags = AS_NAMESPACE_QUALIFIER asETokenFlags::None;
		AS_NAMESPACE_QUALIFIER asETokenFlags ForbiddenFlags = AS_NAMESPACE_QUALIFIER asETokenFlags::None;
	};

	struct FExpectedLexDiagnostic
	{
		AS_NAMESPACE_QUALIFIER asELexDiagnosticID ID;
		asUINT Begin;
		asUINT End;
	};

	struct FLexExpectation
	{
		std::vector<FExpectedToken> Tokens;
		std::vector<FExpectedLexDiagnostic> Diagnostics;
	};

	struct FMalformedUtf8Case
	{
		std::string Name;
		std::string Bytes;
	};

	class FNativeEngineTokenizerTest
	{
	public:
		static FNativeEngineTokenizerTest FromText(FStringView Text);
		static FNativeEngineTokenizerTest FromUtf8Bytes(std::string_view Utf8Bytes);
		~FNativeEngineTokenizerTest();
		FNativeEngineTokenizerTest(FNativeEngineTokenizerTest&& Other);
		FNativeEngineTokenizerTest& operator=(FNativeEngineTokenizerTest&& Other);
		FNativeEngineTokenizerTest(const FNativeEngineTokenizerTest&) = delete;
		FNativeEngineTokenizerTest& operator=(const FNativeEngineTokenizerTest&) = delete;

		FNativeEngineTokenizerTest& WithOptions(const AS_NAMESPACE_QUALIFIER asSLexOptions& Options);

		bool CheckKinds(
			FNoDiscardAsserter& Assert,
			std::span<const AS_NAMESPACE_QUALIFIER asETokenKind> ExpectedKinds,
			std::string_view CaseName = {});
		bool CheckKinds(
			FNoDiscardAsserter& Assert,
			std::initializer_list<AS_NAMESPACE_QUALIFIER asETokenKind> ExpectedKinds,
			std::string_view CaseName = {});
		bool Check(
			FNoDiscardAsserter& Assert,
			const FLexExpectation& Expected,
			std::string_view CaseName = {});

		std::string_view GetSourceBytes() const;
		std::span<const AS_NAMESPACE_QUALIFIER asCToken> GetTokens();
		std::span<const AS_NAMESPACE_QUALIFIER asSDiagnosticRecord> GetDiagnostics();
		const AS_NAMESPACE_QUALIFIER asCToken& GetRepeatedEndOfFile();
		std::string Describe();

		static std::vector<FMalformedUtf8Case> GenerateMalformedUtf8Cases();

	private:
		struct FRunState;
		explicit FNativeEngineTokenizerTest(std::string InSourceBytes);
		void RunOnce();

		std::string SourceBytes;
		AS_NAMESPACE_QUALIFIER asEUnicodeIdentifierPolicy UnicodePolicy =
			AS_NAMESPACE_QUALIFIER asEUnicodeIdentifierPolicy::AsciiOnly;
		AS_NAMESPACE_QUALIFIER asETriviaMode TriviaMode =
			AS_NAMESPACE_QUALIFIER asETriviaMode::SkipTrivia;
		std::unique_ptr<FRunState> RunState;
	};
}
```

The header explicitly includes the standard headers it owns: `<initializer_list>`, `<memory>`, `<span>`, `<string>`, `<string_view>`, and `<vector>`. `std::string` is the byte container as well as the UTF-8 rendered-result container; embedded NUL and malformed bytes remain valid because all input paths retain explicit lengths.

`FromText` is intentionally the one UE-authored text entry. It uses `FTCHARToUTF8(Text.GetData(), Text.Len())` once and copies the returned explicit byte count into `std::string`. `FromUtf8Bytes` copies the supplied `std::string_view` immediately. No `FSourceInput` or `TArray<uint8>` is stored. At `asCSourceSnapshot::AddFile`, the run state adapts `SourceBytes.data()/size()` to the inspected `TConstArrayView<uint8>` with a checked size conversion. At the assertion boundary, a contextual UTF-8 `std::string` is converted with an explicit-length `FUTF8ToTCHAR` before calling `FNoDiscardAsserter::Fail(FString)`. Product/source objects may retain their required UE smart pointers and value types inside `FRunState`; the test-owned strings and collections remain standard-library-owned.

The out-of-line `FRunState` owns the frozen snapshot, source manager, diagnostics engine, identifier table, `std::vector` token/diagnostic captures, and collecting consumer. `std::unique_ptr<FRunState>` makes the addresses used by captured identifier tokens stable while the outer value remains movable.

`WithOptions` is configuration-before-observation: it extracts the immutable option object's Unicode and trivia enum values, then `RunOnce` constructs final `asSLexOptions` by value. It never invokes the deliberately deleted assignment operator. After `GetTokens`, `GetDiagnostics`, `GetRepeatedEndOfFile`, `CheckKinds`, `Check`, or `Describe` starts the run, changing options is a programmer error rather than an implicit second tokenization.

`RunOnce` permits at most `SourceBytes.size()` advancing non-EOF pulls plus the first EOF. It then performs exactly one separate post-EOF `Lex` probe and records it outside the primary token vector. Structural validation requires both EOF tokens to be zero-length at the exact byte count and kind `EndOfFile`; this retains the existing `MalformedBytesAlwaysAdvanceAndDiagnoseOnce` assertion without duplicating EOF in ordinary expected streams. A broken lexer cannot exceed `byte_count + 2` total successful pulls while failure output is assembled.

`CheckKinds` is the concise positive-case path: it compares primary kinds through first EOF and always validates non-zero progress, monotonic in-bounds half-open ranges, exact EOF, stable repeated EOF, and successful one-time diagnostic flush. `Check` adds exact ranges, required/forbidden flags, and typed diagnostic IDs/ranges. Both receive the CQTest `FNoDiscardAsserter`, call its public `Fail(FString)` once with the case name plus `Describe()` output, return `false` after the first structural mismatch, and require callers to consume that result with an early return. No assertion macro is hidden inside the helper.

`GetSourceBytes`, `GetTokens`, and `GetDiagnostics` expose non-owning standard views while the test object remains the sole owner; `GetRepeatedEndOfFile` exposes the distinct sticky-EOF observation; `Describe` returns an owned UTF-8 string. The source-referential contract slices `GetSourceBytes().substr(Begin, End - Begin)` for keyword, identifier, numeric literal, and punctuation tokens and compares the bytes with authored lexemes. Measurement helpers stay in `Contracts` `private:`.

### Bounded negative generation

`GenerateMalformedUtf8Cases` produces stable named `std::string` input rows, not expected output and not Automation registrations. It starts from canonical valid 2/3/4-byte seeds and generates every strict truncation plus one bad-first-continuation mutation per seed, then appends fixed invalid-leader, overlong, surrogate, and above-maximum rows. `Recovery.MalformedUtf8FamiliesAdvanceExactly` supplies the independent expected invariant: first token `Invalid [0,1)`, first diagnostic `InvalidUtf8 [0,1)`, all later non-EOF tokens make progress, and EOF equals the explicit input length.

The generator has its own stable row-name/byte digest test. It is intentionally smaller than fuzzing and does not infer expected kinds or diagnostics from tokenizer output. A future generic generator may import the recipe after `refactor-testing-unified-framework` task 5.1 exists; this Change does not create a generic recipe engine.

### Kind matrix and independent oracle

Walk `asETokenKind` / `asGetTokenSpellingAnsi`; skip the eight empty spellings for lex round trips; add pair rows for `>>`, `**`, `>>>`, `>>=`, `>>>=`, `**=`. This proves every currently advertised spelling tokenizes to its enumerator, but it is not claimed as an independent vocabulary oracle.

Independently freeze the accepted 115-row order/spelling sequence with 64-bit FNV-1a. For each kind value, mix its little-endian `uint16` value, every ANSI spelling byte, and a zero delimiter. The accepted fingerprint is `0xa912c3f84387564e`; the test also checks `Count == 115` and the non-empty count is 107. The literal fingerprint is not generated from the table during the test, so deletion, reorder, or retarget changes fail before the round-trip assertions can self-confirm the mutation.

The compact negative case matrix fixes bytewise keyword matching without copying the whole table: `class/Class/CLASS`, `Cast/cast`, and `UPROPERTY/UProperty/uproperty`. Only the canonical spellings produce `KwClass`, `KwCast`, and `KwUProperty`; all casing mutations are identifiers.

### Clang-derived gaps kept at the tokenizer boundary

The accepted additions stay in the same three scenarios:

- `Contracts` adds exact source slices and empty/pure-trivia stable EOF.
- `SpelledKinds` adds explicit case-sensitive negatives.
- `Recovery` adds a valid U+00A2 nonidentifier row, comment-at-EOF, dangling string escape, CRLF, and exact RetainTrivia/RawDirective kind/range/flag parity.

Macro expansion/spelling locations, pasted/split tokens, header and module search, dependency-directive minimization, preamble, navigation/peek, and C/C++ physical line splicing remain outside the isolated tokenizer. Consumer lookahead and parser handling of nested-generic `>>` remain downstream responsibilities.

### UTF-8 BOM grouped RED and repair

AngelScript 2.38 `asCTokenizer::IsWhiteSpace` explicitly returns one three-byte whitespace token for `EF BB BF`. The reconstructed tokenizer instead decodes U+FEFF and emits `UnicodeIdentifierDisallowed [0,3)` under its default policy. Task 1.3 adds the exact RetainTrivia and SkipTrivia expectations first, observes the grouped RED with the other Recovery cases, and then changes only `frontend/Lexer/as_tokenizer.cpp` so BOM participates in whitespace scanning.

The source snapshot continues to own the original three bytes. RetainTrivia exposes `Whitespace [0,3)`; SkipTrivia advances the next token's range to byte 3. BOM establishes leading space without changing start-of-line and never changes Unicode identifier policy. The behavior is recorded in the lexing delta rather than treated as an incidental test-only fix.

### Recovery and lexical state boundaries

Recovery retains exact checks for malformed UTF-8, embedded NUL, unexpected ASCII input, Unicode policy, quoted strings, comments, and trivia. It adds only branch-complete boundary rows whose current or desired behavior is supported by existing contracts:

- U+00A2 under `AllowUnicode` is valid UTF-8 but not an identifier start, so it produces `UnexpectedCharacter [0,2)` rather than `InvalidUtf8` or `UnicodeIdentifierDisallowed`.
- Empty input reaches `EOF [0,0)` immediately; pure trivia and `//` at EOF reach exact byte-count EOF without over-read.
- A terminal backslash after an opening quote is one unterminated string through the buffer edge.
- CRLF makes the following token `StartOfLine | LeadingSpace`.
- RawDirective is currently a tokenizer label that behaves as RetainTrivia; complete kind/range/flag projections match. Preprocessor directive meaning remains excluded.

Ordinary unterminated strings meeting physical newline are intentionally not frozen: current code consumes the newline but clears start-of-line state, while the durable contract does not decide whether newline belongs to the invalid string or following trivia. CR-only and three/four-byte Unicode identifier categories are likewise deferred rather than inferred from Clang's C/C++ policy.

### Future unified-framework seam

This pilot separates three concerns: owned bytes (`FromText` / `FromUtf8Bytes`), execution/capture (`GetTokens` / `GetDiagnostics` / `GetRepeatedEndOfFile` / `Describe`), and oracle checking (`CheckKinds` / `Check`). Later `refactor-testing-unified-framework` task 5.2 may add a `FAngelscriptTestSource` adapter or replace the local source-copy internals while preserving Lexer expectations. Generic source identity, history, catalogs, typed Automation rows, result artifacts, and reusable generation remain owned by that Change; the lexer helper never becomes a competing center.

### Affected current-spec format prerequisite

Completion verification found that both delta targets predate the current Scenario Card ownership rule: their existing clause-detail lines use two spaces, so strict current-spec validation fails before synchronization. Task 1.4 may change only indentation in `openspec/specs/angelscript/language/frontend/lexing/spec.md` and `openspec/specs/angelscript/testing/baseline/spec.md`. It preserves all non-whitespace text, Requirement/Scenario order, behavior clauses, detail blocks, Markdown nesting, and parentage, and proves both targets strictly valid before sync. This authorization does not widen product behavior or permit formatting unrelated specs.

## Verification

Each task runs the matching editor build followed by its focused `Angelscript.UnitTest.NativeEngine.Lexer` selector. Final acceptance has 18 Contracts methods, four SpelledKinds methods, and nine Recovery methods. Omit Quick, Performance, Integration, and PP/Sema/VM prefixes unless evidence from the BOM repair demonstrates a wider affected contract.
