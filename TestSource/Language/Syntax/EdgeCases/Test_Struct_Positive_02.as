// Theme: Language.Syntax.EdgeCases. Positive USTRUCT with UPROPERTY X.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Struct_Positive block 2 AssertCompiles.
// sha256=f880e24f4b3092175e4377e8fb6d4abca962ffb851734484f5bcb558877b53bc; lines 223-230.
// Oracle: UPROPERTY X defaults to 0.
// Extra: X=0 empty default; writing a copy does not rewrite the original.
// DefaultSafe. Keep UPROPERTY name X.

USTRUCT()
struct FStructUSTRUCT
{
	UPROPERTY()
	int X = 0;
}

int Observe_FStructUSTRUCT_DefaultX()
{
	FStructUSTRUCT S;
	return S.X;
}

int Observe_FStructUSTRUCT_WriteBoundary()
{
	FStructUSTRUCT S;
	S.X = 1;
	return S.X;
}

int Observe_FStructUSTRUCT_CopyIndependentX()
{
	FStructUSTRUCT A;
	A.X = 4;
	FStructUSTRUCT B = A;
	B.X = 0;
	return A.X;
}
