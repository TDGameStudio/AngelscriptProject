// Theme: Language.Literals.FString. Positive Contains/StartsWith/EndsWith/Find/Equals/Compare.
// C++: AngelscriptCoverageFStringMethodTests.cpp::SearchMethods
// sha256 from TS-LANG-0150; lines 151-250.
// Oracle: found/not-found, index 6 / -1 / 8, FindChar/FindLastChar, wildcard, ignore-case, Compare orders.
// Extra: empty Contains false; Find on empty returns -1.
// DefaultSafe. Source owns locals.

bool TestContains_Found()
{
	FString s = "Hello World";
	return s.Contains("World");
}

bool TestContains_NotFound()
{
	FString s = "Hello World";
	return s.Contains("Test");
}

bool TestStartsWith_True()
{
	FString s = "Hello World";
	return s.StartsWith("Hello");
}

bool TestStartsWith_False()
{
	FString s = "Hello World";
	return s.StartsWith("World");
}

bool TestEndsWith_True()
{
	FString s = "Hello World";
	return s.EndsWith("World");
}

bool TestEndsWith_False()
{
	FString s = "Hello World";
	return s.EndsWith("Hello");
}

int TestFind_Found()
{
	FString s = "Hello World";
	return s.Find("World");
}

int TestFind_NotFound()
{
	FString s = "Hello World";
	return s.Find("Test");
}

int TestFindCaseSensitiveMiss()
{
	FString s = "Hello World";
	return s.Find("world", ESearchCase::CaseSensitive);
}

int TestFindFromEnd()
{
	FString s = "One Two One";
	return s.Find("One", ESearchCase::CaseSensitive, ESearchDir::FromEnd);
}

bool TestFindChar()
{
	FString s = "Hello";
	int Index = -1;
	return s.FindChar(0x65, Index) && Index == 1;
}

bool TestFindLastChar()
{
	FString s = "banana";
	int Index = -1;
	return s.FindLastChar(0x61, Index) && Index == 5;
}

bool TestMatchesWildcard()
{
	FString s = "CoverageString";
	return s.MatchesWildcard("Coverage*");
}

bool TestEqualsIgnoreCase()
{
	FString s = "Hello";
	return s.Equals("hello", ESearchCase::IgnoreCase);
}

bool TestEqualsCaseSensitiveMiss()
{
	FString s = "Hello";
	return !s.Equals("hello", ESearchCase::CaseSensitive);
}

bool TestCompareOrdersValues()
{
	FString a = "Alpha";
	FString b = "Beta";
	return a.Compare(b) < 0 && b.Compare(a) > 0;
}

bool Observe_SearchMethods_Nominal()
{
	return TestContains_Found()
		&& !TestContains_NotFound()
		&& TestStartsWith_True()
		&& !TestStartsWith_False()
		&& TestEndsWith_True()
		&& !TestEndsWith_False()
		&& TestFind_Found() == 6
		&& TestFind_NotFound() == -1
		&& TestFindCaseSensitiveMiss() == -1
		&& TestFindFromEnd() == 8
		&& TestFindChar()
		&& TestFindLastChar()
		&& TestMatchesWildcard()
		&& TestEqualsIgnoreCase()
		&& TestEqualsCaseSensitiveMiss()
		&& TestCompareOrdersValues();
}

bool Observe_Contains_EmptyNeedle()
{
	FString s = "Hello World";
	return s.Contains("");
}

int Observe_Find_EmptyHaystackBoundary()
{
	FString Empty;
	return Empty.Find("Test");
}
