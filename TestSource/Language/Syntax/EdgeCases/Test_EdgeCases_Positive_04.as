// Theme: Language.Syntax.EdgeCases. Positive multiple statements in one function.
// C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive block 4 AssertCompiles.
// sha256=e31f69f5265fc485a7d704fc65d845bdad93bbac7e44c6dce04c07cc927d1468; lines 247-249.
// Oracle: A=1, B=2, C=A+B is 3; A and B stay 1 and 2 after the add.
// Extra: 0+0 empty sum; copy of C does not rewrite A.
// DefaultSafe. Source owns locals.

void Test()
{
	int A = 1;
	int B = 2;
	int C = A + B;
}

int Observe_MultiStmt_SumNominal()
{
	int A = 1;
	int B = 2;
	int C = A + B;
	return C;
}

int Observe_MultiStmt_EmptyDefaultZero()
{
	int A = 0;
	int B = 0;
	int C = A + B;
	return C;
}

int Observe_MultiStmt_AddendsUnchanged()
{
	int A = 1;
	int B = 2;
	int C = A + B;
	C = 99;
	return A + B;
}
