// Theme: Language.Literals.FString. Positive: FString.Contains().
// C++: AngelscriptSyntaxFStringTests.cpp::Methods_Positive block 3 AssertCompiles.
// sha256=d9d5af5ef80b588972aa8850f8d2c8f4c19cc1a417aa0eca9736099421c72aa0; lines 224-226.
// Oracle: "Hello World".Contains("World") is true.
// Extra: missing substring is false; empty needle against empty haystack.
// DefaultSafe. Contains does not mutate S.

void Test()
{
	FString S = "Hello World";
	bool B = S.Contains("World");
}

bool Observe_Contains_Nominal()
{
	FString S = "Hello World";
	return S.Contains("World");
}

bool Observe_Contains_MissingBoundary()
{
	FString S = "Hello World";
	return !S.Contains("Missing");
}

bool Observe_Contains_EmptyHaystack()
{
	FString S = "";
	return !S.Contains("World");
}
