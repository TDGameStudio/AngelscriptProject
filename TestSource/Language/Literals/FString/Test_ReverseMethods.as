// Theme: Language.Literals.FString. Positive Reverse and palindrome identity.
// C++: AngelscriptCoverageFStringMethodTests.cpp::ReverseMethods
// sha256=f468efc5b31d906583178ea49776e609c3147383becaa21eb0b532c0c87b33e0; lines 967-979.
// Oracle: TestReverse "olleH"; TestReversePalindrome "racecar".
// Extra: Reverse of empty stays empty; Reverse of single char is identity.
// DefaultSafe. Source owns locals.

FString TestReverse()
{
	FString s = "Hello";
	return s.Reverse();
}

FString TestReversePalindrome()
{
	FString s = "racecar";
	return s.Reverse();
}

bool Observe_ReverseMethods_Nominal()
{
	return TestReverse() == "olleH" && TestReversePalindrome() == "racecar";
}

FString Observe_Reverse_EmptyDefault()
{
	FString Empty;
	return Empty.Reverse();
}

FString Observe_Reverse_SingleCharBoundary()
{
	FString s = "x";
	return s.Reverse();
}
