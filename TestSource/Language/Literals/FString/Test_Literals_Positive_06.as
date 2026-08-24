// Theme: Language.Literals.FString. Positive: f-string interpolates an arithmetic expression.
// C++: AngelscriptSyntaxFStringTests.cpp::Literals_Positive block 6 AssertCompiles.
// sha256=9accba47d80eab4c94f9995f9ebeb47e592cfa56bcce3f69aa4d332029cfd116; lines 95-97.
// Oracle: f"Result: {5 * 2 + 1}" == "Result: 11".
// Extra: X = 0 yields "Result: 1"; mutating X after interpolation leaves S unchanged.
// DefaultSafe.

void Test()
{
	int X = 5;
	FString S = f"Result: {X * 2 + 1}";
}

bool Observe_FStringExpr_Nominal()
{
	int X = 5;
	FString S = f"Result: {X * 2 + 1}";
	return S == "Result: 11";
}

bool Observe_FStringExpr_ZeroBoundary()
{
	int X = 0;
	FString S = f"Result: {X * 2 + 1}";
	return S == "Result: 1";
}

bool Observe_FStringExpr_CopyIndependence()
{
	int X = 5;
	FString S = f"Result: {X * 2 + 1}";
	X = 0;
	return S == "Result: 11";
}
