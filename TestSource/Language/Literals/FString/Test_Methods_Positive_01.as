// Theme: Language.Literals.FString. Positive: FString.Len().
// C++: AngelscriptSyntaxFStringTests.cpp::Methods_Positive block 1 AssertCompiles.
// sha256=121c2e91dde8ffe98120b39b966af31ca83c186eb658e024351c41a817d86b01; lines 212-214.
// Oracle: "Hello".Len() == 5.
// Extra: empty Len 0; Len does not mutate the source.
// DefaultSafe.

void Test()
{
	FString S = "Hello";
	int L = S.Len();
}

int Observe_Len_Nominal()
{
	FString S = "Hello";
	return S.Len();
}

int Observe_Len_EmptyDefault()
{
	FString S = "";
	return S.Len();
}

bool Observe_Len_CopyIndependence()
{
	FString S = "Hello";
	int L = S.Len();
	S = "";
	return L == 5;
}
