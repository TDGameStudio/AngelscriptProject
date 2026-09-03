/**
 * Replacement methods on FString: the copying Replace, the in-place
 * ReplaceInline with its substitution count, case-sensitive misses, and the
 * escape/unescape helpers. Each helper isolates one replacement form.
 *
 * @Theme Language.Literals
 * @Subject Literals.ReplaceMethods
 * @Harness Function
 * @Tag Language.Literals.ReplaceMethods
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringMethodTests.cpp::ReplaceMethods
 * @Provenance sha256 from TS-LANG-0154; lines 474-517.
 * @Provenance Oracle: Hello Universe; orange x3; Hello World; 2:green green blue; Hello World; escaped/unescaped.
 * @Provenance Extra: replace missing needle is identity; empty replace with empty is identity.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace LiteralsTest
{
	/**
	 * Replaces a present substring once.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" with "World" replaced by "Universe"
	 * @Return "Hello Universe"
	 */
	FString ReplaceSingle()
	{
		FString s = "Hello World";
		return s.Replace("World", "Universe");
	}

	/**
	 * Replaces every occurrence of a repeated substring.
	 *
	 * @Covers Literals.FString
	 * @Inputs "apple apple apple" with "apple" replaced by "orange"
	 * @Return "orange orange orange"
	 */
	FString ReplaceMultiple()
	{
		FString s = "apple apple apple";
		return s.Replace("apple", "orange");
	}

	/**
	 * Replaces an absent substring and expects the input unchanged.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" with "Test" replaced by "New"
	 * @Return "Hello World"
	 */
	FString ReplaceNotFound()
	{
		FString s = "Hello World";
		return s.Replace("Test", "New");
	}

	/**
	 * Replaces in place and reports the substitution count.
	 *
	 * @Covers Literals.FString
	 * @Inputs "red red blue" with "red" replaced by "green"
	 * @Return the count and result, formatted as "{count}:{text}"
	 */
	FString ReplaceInlineCounted()
	{
		FString s = "red red blue";
		int Count = s.ReplaceInline("red", "green");
		return FString::Format("{0}:{1}", Count, s);
	}

	/**
	 * Replaces case-sensitively and expects only the exact-case match to move.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello hello" with "hello" replaced by "World"
	 * @Return "Hello World"
	 */
	FString ReplaceCaseSensitiveMiss()
	{
		FString s = "Hello hello";
		return s.Replace("hello", "World", ESearchCase::CaseSensitive);
	}

	/**
	 * Converts real control characters into their escape sequences.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Line\nTab\t"
	 * @Return "Line\\nTab\\t"
	 */
	FString EscapedCharacters()
	{
		FString s = "Line\nTab\t";
		return s.ReplaceCharWithEscapedChar();
	}

	/**
	 * Converts escape sequences back into real control characters.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Line\\nTab\\t"
	 * @Return "Line\nTab\t"
	 */
	FString UnescapedCharacters()
	{
		FString s = "Line\\nTab\\t";
		return s.ReplaceEscapedCharWithChar();
	}

	/**
	 * Observe that every replacement form produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs all replacement helpers
	 * @Return true when all seven outcomes match
	 */
	UFUNCTION()
	bool ReplaceMethodsProduceExpectedValues()
	{
		if (ReplaceSingle() != "Hello Universe")
		{
			return false;
		}

		if (ReplaceMultiple() != "orange orange orange")
		{
			return false;
		}

		if (ReplaceNotFound() != "Hello World")
		{
			return false;
		}

		if (ReplaceInlineCounted() != "2:green green blue")
		{
			return false;
		}

		if (ReplaceCaseSensitiveMiss() != "Hello World")
		{
			return false;
		}

		if (EscapedCharacters() != "Line\\nTab\\t")
		{
			return false;
		}

		return UnescapedCharacters() == "Line\nTab\t";
	}

	/**
	 * Observe that replacing within an empty string yields an empty string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Replace("Test", "New") over an empty string
	 * @Return an empty string
	 * @Boundary empty haystack
	 */
	UFUNCTION()
	FString ReplaceEmptyHaystackBoundary()
	{
		FString Empty;
		return Empty.Replace("Test", "New");
	}

	/**
	 * Observe that a failed replacement leaves the source untouched.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Replace("Test", "New") over "Hello World"
	 * @Return the unchanged source, or "failed" if it moved
	 * @Boundary identity
	 */
	UFUNCTION()
	FString ReplaceNotFoundIdentity()
	{
		FString s = "Hello World";
		FString Copy = s;
		FString Result = s.Replace("Test", "New");

		bool Unchanged = (Result == Copy);
		return Unchanged ? Copy : "failed";
	}
}
