// Theme: Language.Literals.FString. Positive: empty string literal.
// C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 2 AssertCompiles.
// sha256=ecc721446173a5f7fbc15395cdf3923fb8b5367e293905f5a95d62a108b8c27e; lines 57-59.
// Oracle: Test() assigns ""; Observe IsEmpty and Len 0.
// Extra: empty != "x"; empty copy stays empty after source write.
// DefaultSafe.

void Test()
{
	FString S = "";
}

bool Observe_EmptyLiteral_Nominal()
{
	FString S = "";
	return S.IsEmpty() && S.Len() == 0;
}

bool Observe_EmptyLiteral_NonEmptyBoundary()
{
	FString Empty = "";
	FString NonEmpty = "x";
	return Empty != NonEmpty;
}

bool Observe_EmptyLiteral_CopyIndependence()
{
	FString S = "";
	FString Copy = S;
	S = "filled";
	return Copy.IsEmpty();
}
