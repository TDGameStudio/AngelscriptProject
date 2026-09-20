# Unity-safe CQTest helper aliases

## Context

The standard-library helper decision remains accepted, but the user raised an Unreal Unity-build concern about importing the complete `LexerTest` namespace at file scope. A Unity worker may concatenate multiple `.cpp` sources into one translation unit, so a file-scope import can affect code textually following the scenario file.

## Evidence

- UE 5.8 CQTest's `_TEST_CLASS_IMPL_EXT` macro expands `TEST_CLASS_WITH_FLAGS` to a forward declaration, runner, runner instance, and global `struct <Class> : public TTest<...>`; the user-written braces are that struct's class body.
- A compiled Clang probe rejects a namespace using-directive and a qualified using-declaration that names a namespace member inside a class body.
- The same probe accepts an alias declaration such as `using FExpectedToken = LexerTest::FExpectedToken;` in a class body.
- `TEST_METHOD` expands to a method registrar data member plus method declaration when Automation workers are enabled. The alias block may be private, but the class must restore `public:` before these registrations.
- A class-scope alias affects only that class. It does not add the helper name to the containing translation unit, including a generated Unity translation unit.

## Settled Decision

Keep all three `TEST_CLASS_WITH_FLAGS` invocations at global scope and outside namespaces. Begin each class body with only its actually referenced helper aliases under `private:`, then restore `public:` before every `TEST_METHOD`:

| Scenario class | Private aliases |
|---|---|
| `Contracts` | `FNativeEngineTokenizerTest`, `FExpectedToken`, `FLexExpectation` |
| `SpelledKinds` | `FNativeEngineTokenizerTest` |
| `Recovery` | `FNativeEngineTokenizerTest`, `FExpectedToken`, `FExpectedLexDiagnostic`, `FLexExpectation`, `FMalformedUtf8Case` |

Every alias uses the explicit shape `using X = LexerTest::X;`. Do not add a namespace-wide using-directive or a file-scope helper alias. If implementation proves one listed alias unused, remove it; if a scenario genuinely spells another helper type, add only that class-local alias and record the evidence in the owning task.

```cpp
TEST_CLASS_WITH_FLAGS(Recovery, "Angelscript.UnitTest.NativeEngine.Lexer", ...)
{
private:
	using FNativeEngineTokenizerTest = LexerTest::FNativeEngineTokenizerTest;
	using FExpectedToken = LexerTest::FExpectedToken;
	using FExpectedLexDiagnostic = LexerTest::FExpectedLexDiagnostic;
	using FLexExpectation = LexerTest::FLexExpectation;
	using FMalformedUtf8Case = LexerTest::FMalformedUtf8Case;

public:
	TEST_METHOD(MalformedGeneratorIsStableAndIndependent)
	{
		// ...
	}
};
```

## Consequences and Flip Condition

- The prior standard-library decision and `LexerTest` namespace name remain current.
- The file-scope import portion of `talk-20260912-130915-std-helper-and-cqtest-using.md` is superseded; that historical record remains immutable.
- CQTest class tokens, TestDir, public Automation identities, method counts, test behavior, helper interface, Task IDs, and Task DAG do not change.
- Reconsider a file-scope alias only if a future non-Unity build boundary is guaranteed and repeated qualification has demonstrated a concrete cost; a namespace-wide import remains unnecessary because CQTest macros are global.

## Sources

- User decision dated 2026-09-12 accepting `using X = LexerTest::X` to avoid Unity-scope leakage.
- UE 5.8 `Engine/Source/Developer/CQTest/Public/CQTest.h:264-282,287-291,310`.
- Local Clang compilation probes for class-scope directive, using-declaration, and alias-declaration legality.
- `attachments/talks/talk-20260912-130915-std-helper-and-cqtest-using.md`.

