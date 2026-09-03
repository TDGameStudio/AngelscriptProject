/**
 * Non-mutating search methods on FString: Contains, StartsWith, EndsWith, Find
 * in its several modes, FindChar, FindLastChar, MatchesWildcard, Equals and
 * Compare. Each helper isolates one search so a failure names the method.
 *
 * @Theme Language.Literals
 * @Subject Literals.SearchMethods
 * @Harness Function
 * @Tag Language.Literals.SearchMethods
 * @Namespace LiteralsTest
 * @Provenance C++: AngelscriptCoverageFStringMethodTests.cpp::SearchMethods
 * @Provenance sha256 from TS-LANG-0150; lines 151-250.
 * @Provenance Oracle: found/not-found, index 6 / -1 / 8, FindChar/FindLastChar, wildcard, ignore-case, Compare orders.
 * @Provenance Extra: empty Contains false; Find on empty returns -1.
 * @Provenance DefaultSafe. Source owns locals.
 */

namespace LiteralsTest
{
	/**
	 * Searches for a present substring.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" searched for "World"
	 * @Return true
	 */
	bool ContainsFound()
	{
		FString s = "Hello World";
		return s.Contains("World");
	}

	/**
	 * Searches for an absent substring.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" searched for "Test"
	 * @Return false
	 */
	bool ContainsNotFound()
	{
		FString s = "Hello World";
		return s.Contains("Test");
	}

	/**
	 * Checks a matching prefix.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" prefixed by "Hello"
	 * @Return true
	 */
	bool StartsWithMatch()
	{
		FString s = "Hello World";
		return s.StartsWith("Hello");
	}

	/**
	 * Checks a non-matching prefix.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" tested against the suffix "World"
	 * @Return false
	 */
	bool StartsWithMismatch()
	{
		FString s = "Hello World";
		return s.StartsWith("World");
	}

	/**
	 * Checks a matching suffix.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" suffixed by "World"
	 * @Return true
	 */
	bool EndsWithMatch()
	{
		FString s = "Hello World";
		return s.EndsWith("World");
	}

	/**
	 * Checks a non-matching suffix.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" tested against the prefix "Hello"
	 * @Return false
	 */
	bool EndsWithMismatch()
	{
		FString s = "Hello World";
		return s.EndsWith("Hello");
	}

	/**
	 * Finds the index of a present substring.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" searched for "World"
	 * @Return 6
	 */
	int FindPresent()
	{
		FString s = "Hello World";
		return s.Find("World");
	}

	/**
	 * Finds the index of an absent substring.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" searched for "Test"
	 * @Return -1
	 */
	int FindAbsent()
	{
		FString s = "Hello World";
		return s.Find("Test");
	}

	/**
	 * Searches case-sensitively for a differently-cased substring.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello World" searched case-sensitively for "world"
	 * @Return -1
	 */
	int FindCaseSensitiveMiss()
	{
		FString s = "Hello World";
		return s.Find("world", ESearchCase::CaseSensitive);
	}

	/**
	 * Searches backwards for a repeated substring.
	 *
	 * @Covers Literals.FString
	 * @Inputs "One Two One" searched from the end for "One"
	 * @Return 8
	 */
	int FindFromEnd()
	{
		FString s = "One Two One";
		return s.Find("One", ESearchCase::CaseSensitive, ESearchDir::FromEnd);
	}

	/**
	 * Finds the first occurrence of a character and reports its index.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello" searched for 'e'
	 * @Return true when found at index 1
	 */
	bool FindCharReportsIndex()
	{
		FString s = "Hello";
		int Index = -1;

		if (!s.FindChar(0x65, Index))
		{
			return false;
		}

		return Index == 1;
	}

	/**
	 * Finds the last occurrence of a character and reports its index.
	 *
	 * @Covers Literals.FString
	 * @Inputs "banana" searched backwards for 'a'
	 * @Return true when found at index 5
	 */
	bool FindLastCharReportsIndex()
	{
		FString s = "banana";
		int Index = -1;

		if (!s.FindLastChar(0x61, Index))
		{
			return false;
		}

		return Index == 5;
	}

	/**
	 * Matches a string against a wildcard pattern.
	 *
	 * @Covers Literals.FString
	 * @Inputs "CoverageString" matched against "Coverage*"
	 * @Return true
	 */
	bool MatchesWildcardPattern()
	{
		FString s = "CoverageString";
		return s.MatchesWildcard("Coverage*");
	}

	/**
	 * Compares two strings ignoring case.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello" compared against "hello"
	 * @Return true
	 */
	bool EqualsIgnoreCase()
	{
		FString s = "Hello";
		return s.Equals("hello", ESearchCase::IgnoreCase);
	}

	/**
	 * Compares two strings case-sensitively and expects a mismatch.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Hello" compared against "hello"
	 * @Return true, since the comparison must fail
	 */
	bool EqualsCaseSensitiveMiss()
	{
		FString s = "Hello";
		return !s.Equals("hello", ESearchCase::CaseSensitive);
	}

	/**
	 * Compares two strings in both directions.
	 *
	 * @Covers Literals.FString
	 * @Inputs "Alpha" and "Beta" compared both ways
	 * @Return true when the ordering is consistent
	 */
	bool CompareOrdersValues()
	{
		FString a = "Alpha";
		FString b = "Beta";

		if (a.Compare(b) >= 0)
		{
			return false;
		}

		return b.Compare(a) > 0;
	}

	/**
	 * Observe that every search method produces its expected result.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs all search helpers
	 * @Return true when all sixteen outcomes match
	 */
	UFUNCTION()
	bool SearchMethodsProduceExpectedValues()
	{
		if (!ContainsFound())
		{
			return false;
		}

		if (ContainsNotFound())
		{
			return false;
		}

		if (!StartsWithMatch())
		{
			return false;
		}

		if (StartsWithMismatch())
		{
			return false;
		}

		if (!EndsWithMatch())
		{
			return false;
		}

		if (EndsWithMismatch())
		{
			return false;
		}

		if (FindPresent() != 6)
		{
			return false;
		}

		if (FindAbsent() != -1)
		{
			return false;
		}

		if (FindCaseSensitiveMiss() != -1)
		{
			return false;
		}

		if (FindFromEnd() != 8)
		{
			return false;
		}

		if (!FindCharReportsIndex())
		{
			return false;
		}

		if (!FindLastCharReportsIndex())
		{
			return false;
		}

		if (!MatchesWildcardPattern())
		{
			return false;
		}

		if (!EqualsIgnoreCase())
		{
			return false;
		}

		if (!EqualsCaseSensitiveMiss())
		{
			return false;
		}

		return CompareOrdersValues();
	}

	/**
	 * Observe that an empty needle is contained in any string.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Contains("") over "Hello World"
	 * @Return true
	 * @Boundary empty needle
	 */
	UFUNCTION()
	bool ContainsEmptyNeedleBoundary()
	{
		FString s = "Hello World";
		return s.Contains("");
	}

	/**
	 * Observe that searching an empty haystack returns -1.
	 *
	 * @Kind Observe
	 * @Covers Literals.FString
	 * @Inputs Find("Test") over an empty string
	 * @Return -1
	 * @Boundary empty haystack
	 */
	UFUNCTION()
	int FindEmptyHaystackBoundary()
	{
		FString Empty;
		return Empty.Find("Test");
	}
}
