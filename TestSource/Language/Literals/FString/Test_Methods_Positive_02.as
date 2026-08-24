// Theme: Language.Literals.FString. Positive: FString.IsEmpty().
// C++: AngelscriptSyntaxFStringTests.cpp::Methods_Positive block 2 AssertCompiles.
// sha256=a1c039b32c6b41c1c0c749510c26a8bbea53bec4c9c41d918affa5493ba69819; lines 218-220.
// Oracle: "".IsEmpty() is true.
// Extra: "Hello".IsEmpty() is false; default FString is empty.
// DefaultSafe.

void Test()
{
	FString S = "";
	bool B = S.IsEmpty();
}

bool Observe_IsEmpty_Nominal()
{
	FString S = "";
	return S.IsEmpty();
}

bool Observe_IsEmpty_NonEmptyBoundary()
{
	FString S = "Hello";
	return !S.IsEmpty();
}

bool Observe_IsEmpty_DefaultConstructed()
{
	FString Empty;
	return Empty.IsEmpty();
}
