# Standard-library helper ownership and one CQTest namespace import

## Context

After the first tokenizer-boundary replan, the user requested that `FNativeEngineTokenizerTest` use the standard library internally and asked whether `using namespace` need appear only once around the CQTest macro site.

## Evidence

- CQTest `TEST_CLASS_WITH_FLAGS`, `TEST_METHOD`, and `ASSERT_THAT` are global macros. `ASSERT_THAT(IsTrue(...))` expands through the current test object's asserter; no CQTest namespace import is required.
- C++ allows `using namespace LexerTest;` at file/namespace scope or inside a function, but not in a class body.
- The user-confirmed per-helper naming convention is `{Unit}Test`; the lexer helper namespace is therefore `LexerTest`, not the broad `AngelscriptNativeEngineTest` namespace.
- Exact input bytes, generated row names, expected/captured collections, stable run indirection, and rendered failure text can use `std::string`, `std::vector`, and `std::unique_ptr`. `std::string_view` preserves explicit byte length, including NUL and malformed UTF-8; `std::span` supplies non-owning collection views.
- UE/product boundaries still require `FStringView` for authored text, `FTCHARToUTF8`/`FUTF8ToTCHAR` conversion, `TConstArrayView<uint8>` for `asCSourceSnapshot::AddFile`, product token/diagnostic types, and `FNoDiscardAsserter::Fail(FString)`.

## Settled Decision

Use `LexerTest::FNativeEngineTokenizerTest` with standard-library-owned bytes, names, expectations, captures, descriptions, and run indirection. Keep `FromText(FStringView)` for authored UE text and change the exact-byte factory to `FromUtf8Bytes(std::string_view)`. Expose captured data through `std::string_view` and `std::span` and provide an initializer-list convenience overload for `CheckKinds`.

Each scenario translation unit has this one import immediately before its file-scope test class:

```cpp
using namespace LexerTest;

TEST_CLASS_WITH_FLAGS(Contracts, "Angelscript.UnitTest.NativeEngine.Lexer", ...)
```

`SpelledKinds` and `Recovery` use the same shape in their own files. The macro remains global and the `TEST_CLASS_WITH_FLAGS` definition is not wrapped in `namespace LexerTest`.

## Consequences and Flip Condition

- The helper no longer stores `TArray`, `FString`, `TUniquePtr`, or `TConstArrayView` as its test-data model. Temporary adapters at product/CQTest boundaries do not transfer ownership.
- The old talk `talk-20260912-122229-unified-tokenizer-test-boundary.md` is superseded only on namespace and standard-string decisions; its lexer-only ownership, one-run capture, independent-oracle, and future TestCode seam remain valid.
- The historical finding `drafts/findings/test-helper-namespace.md` is superseded on Q32: the latest user request selects one file-scope using-directive rather than class-scope using declarations.
- Revisit the standard-library boundary only if the later unified test framework publishes a different source/result ownership contract that can preserve explicit bytes, stable token lifetimes, and contextual CQTest failures.

## Sources

- User requests dated 2026-09-12 concerning one CQTest using-directive and standard-library internals.
- `attachments/drafts/findings/test-helper-namespace.md`
- `attachments/talks/talk-20260912-122229-unified-tokenizer-test-boundary.md`
- `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/NativeEngineTestSupport.h`
- UE 5.8 CQTest public headers inspected for the macro and asserter expansion.

