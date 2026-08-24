// Theme: Language.Literals.FString. Positive: string literal assignment.
// C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 1 AssertCompiles.
// sha256=f0a5aaca3d715b9e04209b7411bc665a56434e7652e4ae70a7032bdebce360aa; lines 50-52.
// Oracle: Test() assigns "Hello World"; Observe compares that literal.
// Extra: default FString is empty; assignment copies, later source mutation does not alias.
// DefaultSafe.

void Test()
{
	FString S = "Hello World";
}

bool Observe_Literal_Nominal()
{
	FString S = "Hello World";
	return S == "Hello World";
}

bool Observe_Literal_EmptyDefault()
{
	FString Empty;
	return Empty.Len() == 0;
}

bool Observe_Literal_CopyIndependence()
{
	FString S = "Hello World";
	FString Copy = S;
	S = "changed";
	return Copy == "Hello World";
}
