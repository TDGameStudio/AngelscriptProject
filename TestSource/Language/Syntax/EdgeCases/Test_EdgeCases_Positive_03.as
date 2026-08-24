// Theme: Language.Syntax.EdgeCases. Positive long chained addition.
// C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive block 3 AssertCompiles.
// sha256=4dbb6fcb0946a0d771acaaaa06ebdc07720788f0ad75c30a4b5bd69e094555a6; lines 241-243.
// Oracle: 1+...+15 evaluates to 120.
// Extra: empty sum is 0; single-term boundary is 1.
// DefaultSafe. Source owns locals.

void Test()
{
	int X = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 + 11 + 12 + 13 + 14 + 15;
}

int Observe_LongExpr_SumOneToFifteen()
{
	int X = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 + 11 + 12 + 13 + 14 + 15;
	return X;
}

int Observe_LongExpr_EmptyDefaultZero()
{
	int X = 0;
	return X;
}

int Observe_LongExpr_SingleTermBoundary()
{
	int X = 1;
	return X;
}
