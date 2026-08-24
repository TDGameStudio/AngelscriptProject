// Theme: Language.Literals.FString. Positive: FString operator!=.
// C++: AngelscriptSyntaxFStringTests.cpp::Methods_Positive block 5 AssertCompiles.
// sha256=ebcc6082fdff3352afdb6107085080064eaceabddbf46f72b10ef9405a04693b; lines 236-238.
// Oracle: "abc" != "def" is true.
// Extra: "abc" != "abc" is false; empty != "def" is true.
// DefaultSafe.

void Test()
{
	FString A = "abc";
	FString B = "def";
	bool NotEqual = (A != B);
}

bool Observe_CompareNeq_Nominal()
{
	FString A = "abc";
	FString B = "def";
	return A != B;
}

bool Observe_CompareNeq_SameBoundary()
{
	FString A = "abc";
	FString B = "abc";
	return !(A != B);
}

bool Observe_CompareNeq_EmptyDefault()
{
	FString A;
	FString B = "def";
	return A != B;
}
