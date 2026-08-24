// Theme: Language.Literals.FString. Positive Left/Right/Mid/Chop/RemoveFromStart/End.
// C++: AngelscriptCoverageFStringMethodTests.cpp::SubstringMethods
// sha256 from TS-LANG-0153; lines 397-447.
// Oracle: Hello; World; World; World; Hello; World; Value; Value.
// Extra: Left(0) empty; Mid past end empty.
// DefaultSafe. Source owns locals.

FString TestLeft()
{
	FString s = "Hello World";
	return s.Left(5);
}

FString TestRight()
{
	FString s = "Hello World";
	return s.Right(5);
}

FString TestMid()
{
	FString s = "Hello World";
	return s.Mid(6, 5);
}

FString TestMidToEnd()
{
	FString s = "Hello World";
	return s.Mid(6);
}

FString TestLeftChop()
{
	FString s = "Hello World";
	return s.LeftChop(6);
}

FString TestRightChop()
{
	FString s = "Hello World";
	return s.RightChop(6);
}

FString TestRemoveFromStart()
{
	FString s = "PrefixValue";
	bool bRemoved = s.RemoveFromStart("Prefix", ESearchCase::CaseSensitive);
	return bRemoved ? s : "failed";
}

FString TestRemoveFromEnd()
{
	FString s = "ValueSuffix";
	bool bRemoved = s.RemoveFromEnd("Suffix", ESearchCase::CaseSensitive);
	return bRemoved ? s : "failed";
}

bool Observe_SubstringMethods_Nominal()
{
	return TestLeft() == "Hello"
		&& TestRight() == "World"
		&& TestMid() == "World"
		&& TestMidToEnd() == "World"
		&& TestLeftChop() == "Hello"
		&& TestRightChop() == "World"
		&& TestRemoveFromStart() == "Value"
		&& TestRemoveFromEnd() == "Value";
}

FString Observe_Left_ZeroCountEmpty()
{
	FString s = "Hello World";
	return s.Left(0);
}

FString Observe_Mid_PastEndBoundary()
{
	FString s = "Hello World";
	return s.Mid(s.Len());
}
