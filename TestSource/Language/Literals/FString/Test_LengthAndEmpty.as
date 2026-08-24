// Theme: Language.Literals.FString. Positive Len, IsEmpty, ToBool.
// C++: AngelscriptCoverageFStringMethodTests.cpp::LengthAndEmpty
// sha256 from TS-LANG-0149; lines 90-126.
// Oracle: TestLen 5; TestIsEmpty_Empty true; TestIsEmpty_NonEmpty false; TestLenLong 23; ToBool true/false.
// Extra: default FString Len 0 and IsEmpty; ToBool on empty is false.
// DefaultSafe. Source owns locals.

int TestLen()
{
	FString s = "Hello";
	return s.Len();
}

bool TestIsEmpty_Empty()
{
	FString s = "";
	return s.IsEmpty();
}

bool TestIsEmpty_NonEmpty()
{
	FString s = "Test";
	return s.IsEmpty();
}

int TestLenLong()
{
	FString s = "This is a longer string";
	return s.Len();
}

bool TestToBoolTrue()
{
	FString s = "true";
	return s.ToBool();
}

bool TestToBoolFalse()
{
	FString s = "false";
	return s.ToBool();
}

bool Observe_LengthAndEmpty_Nominal()
{
	return TestLen() == 5
		&& TestIsEmpty_Empty()
		&& !TestIsEmpty_NonEmpty()
		&& TestLenLong() == 23
		&& TestToBoolTrue()
		&& !TestToBoolFalse();
}

bool Observe_Length_DefaultEmpty()
{
	FString Empty;
	return Empty.Len() == 0 && Empty.IsEmpty();
}

bool Observe_ToBool_EmptyBoundary()
{
	FString Empty = "";
	return !Empty.ToBool();
}
