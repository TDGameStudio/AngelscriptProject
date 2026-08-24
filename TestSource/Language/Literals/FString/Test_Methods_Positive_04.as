// Theme: Language.Literals.FString. Positive: FString operator==.
// C++: AngelscriptSyntaxFStringTests.cpp::Methods_Positive block 4 AssertCompiles.
// sha256=51f1de98fc7add75a71dc0d69c38a4d49e7bd91bab8dfb4f820c156829d3922b; lines 230-232.
// Oracle: "abc" == "abc" is true.
// Extra: "abc" compared with "def" is false; two empty strings compare equal; equality is by value.
// DefaultSafe.

void Test()
{
	FString A = "abc";
	FString B = "abc";
	bool Equal = (A == B);
}

bool Observe_CompareEq_Nominal()
{
	FString A = "abc";
	FString B = "abc";
	return A == B;
}

bool Observe_CompareEq_DifferentBoundary()
{
	FString A = "abc";
	FString B = "def";
	return !(A == B);
}

bool Observe_CompareEq_EmptyDefault()
{
	FString A = "";
	FString B;
	return A == B;
}
