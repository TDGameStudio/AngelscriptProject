// Theme: Language.Casting. Positive compare an object handle with nullptr.
// C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed AssertCompiles
// Oracle: a null handle is the empty vector; a live actor is not null.
// Extra: null handle is the empty/default vector.
// DefaultSafe. Non-null A is runner-owned.

void Test(AActor A)
{
	if (A == nullptr)
	{
	}
	if (A != nullptr)
	{
	}
}

int Observe_NullCompare_Classify(AActor A)
{
	if (A == nullptr)
	{
		return 0;
	}
	if (A != nullptr)
	{
		return 1;
	}
	return -1;
}
