---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "1.3": ["1.1"]
    "1.4": ["1.1", "1.3"]
---

# Isolate NativeEngine lexer tests and kind coverage

## Goal

Move reconstructed `asCTokenizer` tests out of `NewVersion`, establish one standard-library-owned tokenizer-test class, and prove independently anchored vocabulary plus precise recovery/state coverage under `Angelscript.UnitTest.NativeEngine.Lexer`.

## Architecture

`TestFramework/NativeEngine/NativeEngineTokenizerTest.h/.cpp` owns `LexerTest::FNativeEngineTokenizerTest` with named text/byte factories, standard-library storage/views, captured tokens/diagnostics, concise and detailed checks, a stable repeated-EOF probe, actionable output, and bounded malformed-UTF-8 rows. Scenario TUs live in `NativeEngine/Lexer/` as global CQTest classes `Contracts`, `SpelledKinds`, and `Recovery`; each class privately aliases only the `LexerTest` helpers it references and restores `public:` before its test registrations. The later unified-framework Change may adapt the source boundary but continues to own generic TestCode, catalogs, data rows, and generators. See `design.md`.

## Global constraints

- Do not edit `angelscript/refactor-testing-unified-framework`, add `AS_TEST_SOURCE`, or implement its generic frontend/source/data/generator surfaces.
- `FNativeEngineTokenizerTest` owns byte strings, row names, output text, collections, and stable run indirection with `std::string`, `std::vector`, and `std::unique_ptr`; expose non-owning `std::string_view` / `std::span` views.
- Keep UE types only at authored `FStringView` input, explicit snapshot/AddFile adaptation, product values, and CQTest `Fail(FString)` conversion boundaries.
- Generated negative rows are bounded inputs inside one static Automation method; they do not dynamically register tests or derive expected output from tokenizer output.
- Keep each `TEST_CLASS_WITH_FLAGS` at global scope. Put only its exact `using X = LexerTest::X;` aliases under `private:` in the generated class body, restore `public:` before every `TEST_METHOD`, and add no file-scope helper import or alias.
- Leave the user-owned empty `TestFramework/NativeEngine/1.h` and `NativeEngineASTTest.*` files untouched.
- Task 1.3 edits product tokenizer code only after its grouped BOM expectations are observed RED.
- Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptTest/TestFramework/NativeEngine/NativeEngineTokenizerTest.h  # populate reserved empty file · 1.1
 Plugins/Angelscript/Source/AngelscriptTest/TestFramework/NativeEngine/NativeEngineTokenizerTest.cpp  # populate reserved empty file · 1.1
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Lexer/LexerContractsTests.cpp  # · 1.1
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LexerTests.cpp  # · 1.1
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Lexer/LexerSpelledKindsTests.cpp  # · 1.2
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Lexer/LexerRecoveryTests.cpp  # · 1.3
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_tokenizer.cpp  # BOM repair after grouped RED · 1.3
 openspec/changes/angelscript/test-lexer-isolated-coverage/specs/angelscript/testing/baseline/spec.md  # nested identity · 1.1
 openspec/changes/angelscript/test-lexer-isolated-coverage/specs/angelscript/language/frontend/lexing/spec.md  # BOM behavior · 1.3
 openspec/specs/angelscript/testing/baseline/spec.md  # ownership-indentation prerequisite · 1.4
 openspec/specs/angelscript/language/frontend/lexing/spec.md  # ownership-indentation prerequisite · 1.4
```

## Requirement coverage

| Requirement | Tasks |
|---|---|
| Lexer public path is `…NativeEngine.Lexer.<Scenario>.<Method>` with `Contracts`, `SpelledKinds`, and `Recovery` | 1.1, 1.2, 1.3 |
| Replacement CQTest compiles from `NativeEngine/` under `WITH_ANGELSCRIPT_TESTS` | 1.1 |
| `LexerTest::FNativeEngineTokenizerTest` owns bytes/results through standard containers and provides text/byte factories, simple/detailed checks, source views, repeated EOF, and failure description | 1.1 |
| All 17 existing contract methods keep their assertions and a new empty/pure-trivia contract reaches stable EOF | 1.1 |
| Authored token ranges slice back to exact keyword, identifier, literal, and punctuation bytes | 1.1 |
| The accepted 115-row vocabulary has an independent fingerprint and 107 spelled rows lex correctly | 1.2 |
| Overlapping shift/power spellings retain maximal munch and keyword recognition is case-sensitive | 1.2 |
| Bounded generated malformed UTF-8 rows have a stable recipe and independent recovery oracle | 1.3 |
| Valid nonidentifier Unicode, embedded NUL, unknown input, Unicode continuation, strings, comments, CRLF, and trivia modes assert exact diagnostics/ranges/flags | 1.3 |
| Leading UTF-8 BOM is whitespace with preserved byte ranges and no Unicode diagnostic | 1.3 |
| Full `Angelscript.UnitTest.NativeEngine.Lexer` prefix passes 18 Contracts, four SpelledKinds, and nine Recovery methods | 1.2, 1.3 |
| `NewVersion/NativeEngine/LexerTests.cpp` is gone | 1.1 |
| Both affected current specs satisfy Scenario Card ownership indentation before synchronization without semantic changes | 1.4 |

Self-review 2026-09-12: coverage complete; no placeholder phrases; symbols match `design.md` and the applied replans. Record: `attachments/data/planning-validation.md`.

## [x] 1.1 Land the std-owned tokenizer-test class and move all contracts

The old TU hides source setup, capture, and measurement in an anonymous namespace. This task populates the reserved `NativeEngineTokenizerTest.h/.cpp` pair with one Lexer-specific standard-library-owned test object, moves all seventeen current contract methods to `TEST_CLASS Contracts`, adds an empty/pure-trivia stable-EOF method, and deletes the old TU. Generic source catalogs and test registration stay outside the helper.

**Outcome**

Authored text and exact bytes enter through named factories, one lazy run captures tokens and diagnostics, a distinct probe retains the current sticky-EOF assertion, and CQTest callers can choose kind-only or exact expectations with contextual failure output. The eighteen Contracts methods are discoverable as `Angelscript.UnitTest.NativeEngine.Lexer.Contracts.<Method>`. Excluded: vocabulary matrix (1.2), negative generation and recovery expansion (1.3), TestCode, generic frontend fixtures, and renaming the seventeen current contract methods.

**Interfaces**

Consumes (existing):

```cpp
// NewVersion/NativeEngine/NativeEngineTestSupport.h:22-25 is the inspected conversion precedent.
const FTCHARToUTF8 Converted(Text.GetData(), Text.Len());

// frontend/Basic/as_source_snapshot.h:32
asCSourceFileID asCSourceSnapshot::AddFile(
	FStringView LogicalSourceKey,
	TConstArrayView<uint8> Utf8Bytes);

// frontend/Lexer/as_tokenizer.h:29, :41, :42
asCTokenizer(const asCSourceManager&, const asCSourceRange&, const asSLexOptions&,
	asCIdentifierTable&, asCDiagnosticsEngine&);
bool Lex(asCToken& OutToken);
bool FlushDiagnostics();

// UE 5.8 Developer/CQTest/Public/Assert/NoDiscardAsserter.h:7, :19
struct FNoDiscardAsserter
{
	void Fail(FString Error);
};
```

Produces (namespace `LexerTest` follows the user-confirmed per-unit `{Unit}Test` convention; fixture/file names come from the reserved helper pair):

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
		bool CheckKinds(FNoDiscardAsserter& Assert,
			std::span<const AS_NAMESPACE_QUALIFIER asETokenKind> ExpectedKinds,
			std::string_view CaseName = {});
		bool CheckKinds(FNoDiscardAsserter& Assert,
			std::initializer_list<AS_NAMESPACE_QUALIFIER asETokenKind> ExpectedKinds,
			std::string_view CaseName = {});
		bool Check(FNoDiscardAsserter& Assert,
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
		std::string SourceBytes;
		std::unique_ptr<FRunState> RunState;
	};
}

TEST_CLASS_WITH_FLAGS(Contracts, "Angelscript.UnitTest.NativeEngine.Lexer", …)
{
private:
	using FNativeEngineTokenizerTest = LexerTest::FNativeEngineTokenizerTest;
	using FExpectedToken = LexerTest::FExpectedToken;
	using FLexExpectation = LexerTest::FLexExpectation;

public:
	// Eighteen TEST_METHOD declarations and bodies.
};
```

`FromText` converts once with explicit-length `FTCHARToUTF8`; `FromUtf8Bytes` copies the caller view immediately. Both paths store a `std::string` before creating a snapshot. `FRunState` keeps product objects and all addresses referenced by captured tokens stable, while tokens and emitted diagnostics are retained in `std::vector`. Snapshot `AddFile` receives a checked `TConstArrayView<uint8>` adapter over the owned bytes. Failure text remains UTF-8 `std::string` until an explicit-length `FUTF8ToTCHAR` conversion feeds `Fail(FString)`.

`WithOptions` extracts Unicode/trivia enum values and never assigns the intentionally non-assignable `asSLexOptions`. The first observation freezes configuration, allows at most one advancing token per source byte plus first EOF, then performs exactly one separate repeated-EOF pull. The primary token vector contains one EOF; `GetRepeatedEndOfFile` exposes the second. `CheckKinds` validates progress, monotonic in-bounds ranges, first EOF, stable repeated EOF, and one successful diagnostic flush; `Check` additionally compares exact token/diagnostic fields. Both report one contextual mismatch and return `false` so the test method can stop without cascaded assertions.

**Cases**

1. **ContractsPublicIdentity** — new RED · behavior
   Given the moved TU When Automation discovers replacement tests Then `Angelscript.UnitTest.NativeEngine.Lexer.Contracts.FrozenOptionsAreValueOwned` is present and `Angelscript.UnitTest.NativeEngine.Lexer.FrozenOptionsAreValueOwned` is absent.

2. **UnifiedHelperTextAndByteInputs** — new RED · behavior
   Given text `class X` through `FromText`, explicit byte view `++` through `FromUtf8Bytes`, and `π` configured from a block-local `AllowUnicode` option When caller storage has left scope and `CheckKinds`/`Check` run Then sequences are `{KwClass, Identifier, EOF}`, `{PlusPlus, EOF}`, and `{Identifier [0,2) ContainsUnicode, EOF}`; `GetSourceBytes().size()` is 7, 2, and 2 respectively.

3. **SourceRangesRecoverAuthoredBytes** — new RED · behavior
   Given UTF-8 source `class Name 42 >>` When `TokenContractIsSourceReferentialAndDeclarative` checks primary tokens Then slicing `GetSourceBytes()` with each `[Begin, End)` yields exactly `class`, `Name`, `42`, and `>>`; kinds are `KwClass`, `Identifier`, `NumericLiteral`, and `ShiftRight`, followed by `EOF [16,16)`, and `Describe()` emits those tokens in deterministic order.

4. **RepeatedEofRemainsExplicit** — existing control · behavior
   Given bytes `{FF, 00, '$', '"', 'x'}` in `MalformedBytesAlwaysAdvanceAndDiagnoseOnce` When the helper finishes its primary stream and performs the separate post-EOF probe Then both EOF tokens are `EndOfFile [5,5)`, the repeated token has length zero, and the primary token sequence still contains only one EOF. This retains the assertions currently at `LexerTests.cpp:418-421`.

5. **EmptyAndTriviaOnlySourcesReachStableEOF** — new RED · boundary
   Given empty bytes and text ` \t\r\n` under SkipTrivia When checked Then the first rows reach `EOF [0,0)` and `EOF [4,4)` respectively, both repeated EOF probes match the primary EOF, the whitespace row's EOF requires `StartOfLine | LeadingSpace`, and neither row emits a diagnostic.

6. **AllCurrentContractsDiscovered** — new RED · behavior
   Given prefix `Angelscript.UnitTest.NativeEngine.Lexer.Contracts` When Automation runs Then these seventeen migrated methods plus `EmptyAndTriviaOnlySourcesReachStableEOF` are discovered and pass: `FrozenOptionsAreValueOwned`, `CharacterStreamUsesValidatedSnapshotRange`, `TokenContractIsSourceReferentialAndDeclarative`, `PullLexerClassifiesKeywordsReflectionSpellingsLiteralsAndPunctuation`, `OnlySixOuterAnnotationsAndCallableIntroducersAreKeywords`, `LeadingDotExponentAndRadixNumbersRetainWholeTokens`, `HexadecimalEDigitDoesNotAbsorbAdjacentAddition`, `RepeatedIdentifiersReuseOneSessionEntry`, `HeredocIsOneLiteralAcrossNewlinesAndEmbeddedQuotes`, `PostfixAndNestedGenericPunctuationPreserveMaximalMunch`, `IndependentSessionsProduceIdenticalTokenProjection`, `UnicodePolicyIsFrozenPerTokenizer`, `MalformedBytesAlwaysAdvanceAndDiagnoseOnce`, `UnterminatedBlockCommentConsumesToEnd`, `TriviaModesPreserveNonTriviaRanges`, `IndependentParallelSessionsRemainDeterministic`, `RepresentativeCorpusRecordsColdAndWarmEvidence`.

7. **CqtestHelperAliasesStayClassScoped** — new RED · structure
   Given `LexerContractsTests.cpp` under the replacement compile gate When the module compiles Then global `TEST_CLASS_WITH_FLAGS` contains private aliases exactly for `FNativeEngineTokenizerTest`, `FExpectedToken`, and `FLexExpectation`, restores `public:` before all `TEST_METHOD` registrations, contains no namespace-wide using-directive, file-scope helper alias, or file-scope anonymous namespace, and the public class identity remains `Contracts`.

8. **OldLexerTuGone** — new RED · structure
   Given the task Files When the module compiles Then `NewVersion/NativeEngine/LexerTests.cpp` does not exist and the reserved tokenizer helper files are non-empty while `1.h` / `NativeEngineASTTest.*` retain their pre-task bytes.

**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptTest/TestFramework/NativeEngine/NativeEngineTokenizerTest.h
 Plugins/Angelscript/Source/AngelscriptTest/TestFramework/NativeEngine/NativeEngineTokenizerTest.cpp
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Lexer/LexerContractsTests.cpp
-Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LexerTests.cpp
```

The first two paths are reserved empty files to populate. No other `TestFramework/NativeEngine` or `NewVersion` file is owned.

**Verification**

```powershell
Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Lexer'; Fast = $true; TimeoutMs = 600000 }
```

Working directory: selected workspace root. Completion: both Harness envelopes have `status = Succeeded`; the Contracts class reports exactly the eighteen methods in case 6, source/repeated-EOF checks from cases 2-5 pass, no old flat method is reported, and source checks from cases 7-8 hold. `SpelledKinds` and `Recovery` remain absent until their sibling tasks land. Quick, Performance, and Integration are intentionally omitted.

**Evidence**

2026-09-12: Behavioral RED compiled successfully in Harness build run `0dedb9cb851240f3a1764f9592756fdd`; Harness test run `fa3173be5e8743b099df880cb3552bfa` discovered 20 tests, kept all 17 old flat controls green, and failed only the three new `Contracts` methods with the deliberate `tokenizer test run is not implemented` seam. GREEN Harness build run `ee25abaf892d4f0c9c32c2f0c2d64423` succeeded; Harness test run `5f269d67ad6f405793abb2cdedf2e4bc` reported exactly 18/18 `Angelscript.UnitTest.NativeEngine.Lexer.Contracts.*` methods passed with zero warnings/errors and no old flat identity. Source inspection confirmed the three planned class-scoped aliases, 18 registrations, populated tokenizer helper files, absent old Lexer TU, and unchanged zero-byte `1.h` / `NativeEngineASTTest.*` placeholders (SHA-256 `e3b0c442...b855`). Quick, Performance, Integration, and broader Automation were omitted because the impact remains the isolated tokenizer prefix.

## [x] 1.2 Add the anchored spelled-kind walk, maximal munch, and case policy

After this task `TEST_CLASS SpelledKinds` uses the helper to walk all 107 non-empty `asGetTokenSpellingAnsi` rows, while a fixed fingerprint independently freezes the full 115-row order/spelling sequence. Additional sources prove longest-match and case-sensitive keyword behavior. The eight empty-spelling kinds remain exercised by Contracts and Recovery stories.

**Outcome**

Every currently advertised non-empty spelling lexes to its enumerator, the accepted vocabulary is protected against deletion/reorder/retarget, and representative canonical/mutated casing distinguishes keywords from identifiers. Excluded: a hand-copied 107-row table, recovery generation, AST `.def` walks, token-name/metadata fingerprint expansion, and product table edits.

**Interfaces**

Consumes (1.1 and existing `frontend/Lexer/as_token.h:13`, `:41`, `:67`):

```cpp
enum class asETokenKind : uint16 { /* .def rows */, Count };
inline const TCHAR* asGetTokenKindName(asETokenKind Kind);
inline const ANSICHAR* asGetTokenSpellingAnsi(asETokenKind Kind);

static FNativeEngineTokenizerTest FNativeEngineTokenizerTest::FromUtf8Bytes(
	std::string_view Utf8Bytes);
bool FNativeEngineTokenizerTest::CheckKinds(
	FNoDiscardAsserter& Assert,
	std::span<const asETokenKind> ExpectedKinds,
	std::string_view CaseName);
```

Produces (`SpelledKinds` comes from the approved glossary; the Unity-safe alias boundary comes from the user-directed replan):

```cpp
TEST_CLASS_WITH_FLAGS(SpelledKinds, "Angelscript.UnitTest.NativeEngine.Lexer", …)
{
private:
	using FNativeEngineTokenizerTest = LexerTest::FNativeEngineTokenizerTest;
	static constexpr uint64 AcceptedTokenVocabularyFnv1a = 0xa912c3f84387564eull;

public:
	// Four TEST_METHOD declarations and bodies.
};
```

Public path: `Angelscript.UnitTest.NativeEngine.Lexer.SpelledKinds.<Method>`. File `LexerSpelledKindsTests.cpp` comes from the approved layout.

**Cases**

1. **SpelledKindsRoundTrip** — new RED · behavior
   Given every `asETokenKind` in `[0, Count)` When its ANSI spelling S is non-empty Then `FromUtf8Bytes(S).CheckKinds` yields `{Kind, EndOfFile}`, the first range is `[0, S.size())`, its source slice equals S, and exactly 107 rows execute. The eight empty rows are skipped only for this round trip.

2. **AcceptedVocabularyFingerprint** — new RED · behavior
   Given all enum rows in order When 64-bit FNV-1a starts at `14695981039346656037`, then mixes each little-endian `uint16` kind value, every ANSI spelling byte, and a zero delimiter with prime `1099511628211` Then the result is the independent literal `0xa912c3f84387564e`, `Count` is 115, and the non-empty count is 107. No expected constant is generated during the test.

3. **OverlappingSpellingsUseMaximalMunch** — new RED · behavior
   Given sources `">>"`, `"**"`, `">>>"`, `">>="`, `">>>="`, and `"**="` When `CheckKinds` runs Then each source is one non-EOF token covering its full byte length with respective kinds `ShiftRight`, `Power`, `ShiftRightArithmetic`, `ShiftRightEqual`, `ShiftRightArithmeticEqual`, and `PowerEqual`.

4. **KeywordRecognitionIsCaseSensitive** — new RED · behavior
   Given source `class Class CLASS Cast cast UPROPERTY UProperty uproperty` When checked Then kinds before EOF are `{KwClass, Identifier, Identifier, KwCast, Identifier, KwUProperty, Identifier, Identifier}` in that order, source slices retain the exact authored casing, and no diagnostic is emitted.

5. **CqtestHelperAliasesStayClassScoped** — new RED · structure
   Given `LexerSpelledKindsTests.cpp` When the module compiles Then global `TEST_CLASS_WITH_FLAGS` contains only the private helper alias `FNativeEngineTokenizerTest`, restores `public:` before all `TEST_METHOD` registrations, contains no namespace-wide using-directive or file-scope helper alias, and the public class identity remains `SpelledKinds`.

6. **ContractsRemainGreen** — existing control · behavior
   Given the full Lexer prefix When Automation runs after this task Then all eighteen Contracts methods from 1.1 remain green alongside the four SpelledKinds methods.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Lexer/LexerSpelledKindsTests.cpp
```

Task 1.1 owns the helper interface; this task consumes it without adding a second fixture.

**Verification**

```powershell
Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Lexer'; Fast = $true; TimeoutMs = 600000 }
```

Working directory: selected workspace root. Completion: both Harness envelopes have `status = Succeeded`; all four SpelledKinds methods and all eighteen Contracts methods pass. Line coverage and PP/Sema selectors are intentionally omitted.

**Evidence**

2026-09-12: The new tests were absent before this task; after authoring the independent oracles, the first runnable characterization was already GREEN, so no product failure was manufactured. Harness build run `be6a6cbd97df4d6e9cf07346772ef93d` succeeded and Harness test run `d32f55c9368842c1a40661b4d42e49ad` reported 22/22 passed with zero warnings/errors: the four exact `SpelledKinds` methods plus all 18 Contracts controls. `SpelledKindsRoundTrip` executed 107 non-empty spellings, `AcceptedVocabularyFingerprint` independently matched 115 rows and literal `0xa912c3f84387564e`, and the maximal-munch/case matrices passed. Source inspection confirmed the sole planned class-scoped helper alias and four registrations. Line coverage and PP/Sema selectors were omitted because this task only freezes the Lexer vocabulary boundary.

## [x] 1.3 Prove exact recovery/state boundaries and repair BOM handling

The old mixed malformed-input method asserts forward progress and only an aggregate diagnostic count. This task adds `TEST_CLASS Recovery`, exercises a deterministic malformed-UTF-8 input generator, proves exact byte/range/state boundaries, observes UTF-8 BOM expectations RED, and then performs the smallest tokenizer repair that makes BOM whitespace. The generator produces inputs only; expectations remain independently authored in the test.

**Outcome**

Lexer recovery is proved by named reproducible rows with actionable captured output. Every malformed row consumes bytes and reaches stable EOF; individual diagnostics cannot silently change identity or range. Leading BOM becomes three-byte whitespace without a Unicode diagnostic. Excluded: random/property fuzz infrastructure, dynamic Automation registration, generic recipe catalogs, parser/preprocessor behavior, ordinary string/newline policy, CR-only policy, non-BMP identifier policy, and broad performance gates.

**Interfaces**

Consumes (1.1 and existing `frontend/Lexer/as_tokenizer.h:16`, `:29`, `:41`, `:42`):

```cpp
enum class asELexDiagnosticID : asUINT
{
	InvalidUtf8 = 1001,
	UnicodeIdentifierDisallowed = 1002,
	EmbeddedNul = 1003,
	UnexpectedCharacter = 1004,
	UnterminatedString = 1005,
	UnterminatedBlockComment = 1006,
};

static std::vector<FMalformedUtf8Case>
FNativeEngineTokenizerTest::GenerateMalformedUtf8Cases();
bool FNativeEngineTokenizerTest::Check(
	FNoDiscardAsserter& Assert,
	const FLexExpectation& Expected,
	std::string_view CaseName);
```

Produces (`Recovery` follows the approved noun convention; BOM changes existing tokenizer behavior without adding a public C++ name):

```cpp
TEST_CLASS_WITH_FLAGS(Recovery, "Angelscript.UnitTest.NativeEngine.Lexer", …)
{
private:
	using FNativeEngineTokenizerTest = LexerTest::FNativeEngineTokenizerTest;
	using FExpectedToken = LexerTest::FExpectedToken;
	using FExpectedLexDiagnostic = LexerTest::FExpectedLexDiagnostic;
	using FLexExpectation = LexerTest::FLexExpectation;
	using FMalformedUtf8Case = LexerTest::FMalformedUtf8Case;

public:
	// Nine TEST_METHOD declarations and bodies.
};
```

Public path: `Angelscript.UnitTest.NativeEngine.Lexer.Recovery.<Method>`. File `LexerRecoveryTests.cpp` comes from the approved layout. Product implementation path is `frontend/Lexer/as_tokenizer.cpp`, verified from the live source rather than the superseded phase-flat filename.

**Cases**

1. **MalformedGeneratorIsStableAndIndependent** — new RED · behavior
   Given valid seeds `{C2 A2}`, `{E2 82 AC}`, and `{F0 90 80 80}` When `GenerateMalformedUtf8Cases` creates every strict prefix and one first-continuation-to-`20` mutation per seed, then appends `{80}`, `{FF}`, `{C0 AF}`, `{E0 80 AF}`, `{F0 80 80 AF}`, `{ED A0 80}`, and `{F4 90 80 80}` Then it emits 16 unique named rows. FNV-1a over each ASCII name, zero delimiter, row bytes, and zero delimiter in output order is fixed at `0x5b75772962a8f9f5`; the generator emits no expected token or diagnostic values.

   Exact ordered name/byte rows are `truncated-2-1=C2`; `truncated-3-1=E2`; `truncated-3-2=E2 82`; `truncated-4-1=F0`; `truncated-4-2=F0 90`; `truncated-4-3=F0 90 80`; `bad-continuation-2=C2 20`; `bad-continuation-3=E2 20 AC`; `bad-continuation-4=F0 20 80 80`; `invalid-continuation-leader=80`; `invalid-leader=FF`; `overlong-2=C0 AF`; `overlong-3=E0 80 AF`; `overlong-4=F0 80 80 AF`; `surrogate=ED A0 80`; `above-unicode-max=F4 90 80 80`.

2. **MalformedUtf8FamiliesAdvanceExactly** — new RED · behavior
   Given every generated row When pulled to EOF Then the first token is `Invalid [0,1)`, the first diagnostic is `InvalidUtf8 [0,1)`, every malformed byte token spans one byte with one matching `InvalidUtf8` diagnostic, any ASCII space from a mutation is trivia without a diagnostic, every non-EOF token has a non-empty monotonic in-bounds range, and primary/repeated EOF both begin at the explicit row byte length. Failure context includes the stable row name and hex input.

3. **EmbeddedNulAndUnknownInputStayDistinct** — new RED · behavior
   Given bytes `{'a', 00, '$', 'b'}` When checked Then kinds/ranges are `Identifier [0,1)`, `Invalid [1,2)`, `Invalid [2,3)`, `Identifier [3,4)`, `EndOfFile [4,4)` and diagnostics are exactly `EmbeddedNul [1,2)` followed by `UnexpectedCharacter [2,3)`.

4. **ValidUnicodeNonIdentifierUsesUnexpectedCharacter** — new RED · boundary
   Given bytes `{C2 A2}` for U+00A2 under `AllowUnicode` When checked Then `Invalid [0,2)` carries `StartOfLine | ContainsUnicode`, its diagnostic is exactly `UnexpectedCharacter [0,2)`, and it is distinguished from malformed UTF-8 and policy-disabled Unicode before stable EOF `[2,2)`.

5. **UnicodeContinuationRespectsFrozenPolicy** — new RED · behavior
   Given UE text `nameπ` encoded by `FromText` When checked with `AllowUnicode` Then one `Identifier [0,6)` carries `ContainsUnicode`; When checked with `AsciiOnly` Then `Identifier [0,4)` is followed by `Invalid [4,6)`, one `UnicodeIdentifierDisallowed [4,6)` diagnostic, and EOF. The six-byte result proves UTF-8 byte offsets rather than TCHAR counts.

6. **QuotedStringsTerminateOrDiagnoseExactly** — new RED · behavior
   Given exact byte sequences `"a\"b"`, `'a\'b'`, `"abc`, `"""abc`, and terminal `"\` When checked Then the escaped forms are one terminated `StringLiteral` spanning 6 bytes with no diagnostic; the regular, triple, and dangling-escape rows are one unterminated token over `[0,4)`, `[0,6)`, and `[0,2)` respectively. Each unterminated token carries `Unterminated` and one `UnterminatedString` diagnostic over the same range.

7. **CommentAtBufferEndTerminatesExactly** — new RED · boundary
   Given exact bytes `//` under RetainTrivia When checked Then the primary stream is `LineComment [0,2)` with `StartOfLine`, then `EOF [2,2)` with `StartOfLine | LeadingSpace`; the repeated EOF matches and no diagnostic is emitted.

8. **TriviaAndCommentTransitionsPreserveFlags** — new RED · behavior
   Given `x /*a\r\nb*/ y\r\n//c\r\nz` When checked in SkipTrivia and RetainTrivia modes Then non-trivia kind/range/flag projections are identical, `y` and `z` carry `StartOfLine | LeadingSpace`, retained tokens contain one terminated block comment and one line comment, and no diagnostic is emitted. Given directive-shaped source `//c\n#x` under RetainTrivia and RawDirective When compared Then complete token kind/range/flag projections and diagnostics are identical; preprocessing meaning of `#x` is not asserted. The migrated `UnterminatedBlockCommentConsumesToEnd` remains the negative comment control.

9. **Utf8BomIsWhitespace** — new RED · behavior
   Given bytes `{EF BB BF}` under `AsciiOnly + RetainTrivia` When first observed before product repair Then the current tokenizer returns `Invalid [0,3)` plus `UnicodeIdentifierDisallowed`, establishing grouped RED. After the repair, the exact stream is `Whitespace [0,3)` requiring `StartOfLine`, `EOF [3,3)` requiring `StartOfLine | LeadingSpace`, stable repeated EOF, and no diagnostics. Given `{EF BB BF}class` under SkipTrivia Then `KwClass [3,8)` requires `StartOfLine | LeadingSpace`, followed by stable `EOF [8,8)`, with no diagnostics.

10. **CqtestHelperAliasesStayClassScoped** — new RED · structure
    Given `LexerRecoveryTests.cpp` When the module compiles Then global `TEST_CLASS_WITH_FLAGS` contains private aliases exactly for `FNativeEngineTokenizerTest`, `FExpectedToken`, `FExpectedLexDiagnostic`, `FLexExpectation`, and `FMalformedUtf8Case`, restores `public:` before all `TEST_METHOD` registrations, contains no namespace-wide using-directive or file-scope helper alias, and the public class identity remains `Recovery`.

11. **SiblingScenariosRemainGreen** — existing control · behavior
    Given the full Lexer prefix When Automation runs at this task state Then all eighteen Contracts methods and nine Recovery methods pass through the same helper; all four SpelledKinds methods also pass when sibling task 1.2 is present. Sibling execution order does not alter task acceptance.

**Files**

```diff
+Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/Lexer/LexerRecoveryTests.cpp
 Plugins/Angelscript/Source/AngelscriptRuntime/angelscript/frontend/Lexer/as_tokenizer.cpp  # BOM only after case 9 is observed RED
```

No generic Framework, TestCode, parser, preprocessor, identifier-table, legacy, or sibling TestFramework placeholder file is owned.

**Verification**

```powershell
Invoke-Harness -Command ue.build -Context $context -Parameters @{ TimeoutMs = 1800000 }
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Lexer'; Fast = $true; TimeoutMs = 600000 }
```

Working directory: selected workspace root. Completion: both Harness envelopes have `status = Succeeded`; all nine Recovery methods expose the exact generated-row, token, range, flag, diagnostic, buffer-edge, parity, and BOM evidence; all eighteen Contracts methods and all available SpelledKinds methods pass. Quick, Performance, Integration, random fuzzing, and PP/Sema/VM selectors are intentionally omitted because the change remains at the tokenizer boundary and the BOM repair does not alter consumers.

**Evidence**

2026-09-12: The complete Recovery group compiled before product repair in Harness build run `671a621959a449b18583fa10c507249d`. RED Harness test run `6c09d242e4d648da997e8cba4be6b467` discovered all 31 target methods and reported 30 passed / one failed: only `Recovery.Utf8BomIsWhitespace`, with actual `Invalid [0,3)` flags 9 and `UnicodeIdentifierDisallowed [0,3)` against bytes `EFBBBF`; all other eight Recovery methods and 22 sibling controls passed. Inspection demonstrated that the ASCII-only whitespace dispatch excluded BOM and therefore routed decoded U+FEFF into the Unicode-policy diagnostic branch. After adding only the three-byte BOM predicate to the existing whitespace dispatch/scan, GREEN Harness build run `f6e6598b9a194e7d9cfb7f0e45b8034a` succeeded and Harness test run `5b7013ecb9e54156989da9b4a289dc70` reported exactly 31/31 passed with zero warnings/errors (18 Contracts, four SpelledKinds, nine Recovery). Source inspection confirmed the five planned class-scoped aliases and nine registrations. Quick, Performance, Integration, random fuzzing, and PP/Sema/VM selectors were omitted because the demonstrated impact is confined to tokenizer whitespace classification and the exact Lexer prefix proves all affected contracts.

After the completion inspection restored the migrated token-metadata assertions, final-content Harness build run `bfecef23c75145e1af2a8cabab9291b8` succeeded and the shared Harness test run `b591e841a50e4bbaa37bd60bafb27a97` again reported 31/31 passed, zero warnings/errors, mapped as Contracts 18 (task 1.1), SpelledKinds four (task 1.2), and Recovery nine (task 1.3). The Automation report is `Saved/Harness/Unreal/Runs/b591e841a50e4bbaa37bd60bafb27a97/AutomationReport/index.json`; its binary was produced by the immediately preceding final-content build.

## [x] 1.4 Normalize affected current-spec Scenario Card ownership indentation

Completion verification proved that the two current specs targeted by this Change fail strict validation before synchronization because their pre-existing direct clause detail uses two-space indentation. Normalize only the Markdown ownership indentation required by the current Scenario Card contract; do not rewrite behavior, wording, order, or parentage.

**Outcome**

`angelscript/language/frontend/lexing` and `angelscript/testing/baseline` pass strict current-spec validation before delta synchronization. Comparing normalized text after removing leading whitespace from every line yields the exact pre-task text, and every Requirement, Scenario, behavior clause, detail block, list/table row, and owning relationship remains unchanged. No other current spec or implementation file is edited.

**Cases**

1. **LexingCurrentSpecUsesOwnedDetailIndentation** — verification-discovered format repair
   Given the clean current lexing spec and strict validation failure run `abbfe24103474acda6ece10d790d644a` When direct clause detail and nested continuation indentation is normalized to four-space ownership Then strict spec validation succeeds with identical non-whitespace line content and Scenario parentage.

2. **TestingBaselineCurrentSpecUsesOwnedDetailIndentation** — verification-discovered format repair
   Given the clean current testing-baseline spec and strict validation failure run `ecd73d17a4864c938a7e894bb91d5537` When the same bounded normalization is applied Then strict spec validation succeeds with identical non-whitespace line content and Scenario parentage.

3. **FormattingScopeStaysBounded** — structure
   Given the task Files When the repair is inspected Then only the two listed current specs change, no behavior-clause text is added/removed/reordered, and no implementation, delta, unrelated spec, or completed task evidence changes.

**Files**

```diff
 openspec/specs/angelscript/language/frontend/lexing/spec.md
 openspec/specs/angelscript/testing/baseline/spec.md
```

**Verification**

```powershell
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/language/frontend/lexing', '--type', 'spec', '--strict')
Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/testing/baseline', '--type', 'spec', '--strict')
```

Working directory: selected workspace root. Completion: both Harness envelopes have `status = Succeeded`; a whitespace-normalized before/after comparison proves identical line content and order; source status contains only the two authorized current specs for this task. UE build and Automation are intentionally omitted because task 1.4 changes Markdown indentation only and final implementation behavior already has a fresh mapped shared run.

**Evidence**

2026-09-12: Added exactly two ownership spaces to every nonblank line that previously began with exactly two spaces in the two authorized current specs. The lexing spec retained 88 lines and its per-line leading-whitespace-stripped SHA-256 remained `ad3f53d17cf8993923f02b42dee849f377b80b6c89bf2aed1cf6caeaeeade81e`; the testing-baseline spec retained 254 lines and its equivalent SHA-256 remained `1c62bee83f3711af94bbcd5ac0112524ce5d7f88880994e10c8a096c147ec37f`. `git diff --word-diff=porcelain --ignore-all-space` produced no semantic diff and `git diff --check` reported no errors. Harness strict validation run `aa7646d46a644933885d3d693e86bf36` passed `angelscript/language/frontend/lexing`, and run `1d0bdcff9960456e9881aeff23bbe698` passed `angelscript/testing/baseline`. No implementation, delta, or unrelated current spec was edited for task 1.4. UE build and Automation were omitted as planned because this task changes Markdown indentation only; final implementation behavior remains proven by build `bfecef23c75145e1af2a8cabab9291b8` and Lexer run `b591e841a50e4bbaa37bd60bafb27a97` (31/31).
