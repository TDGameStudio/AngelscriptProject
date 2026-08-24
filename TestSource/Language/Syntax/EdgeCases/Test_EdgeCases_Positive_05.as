// Theme: Language.Syntax.EdgeCases. Positive deeply parenthesized add.
// C++: AngelscriptSyntaxMiscTests.cpp::EdgeCases_Positive block 5 AssertCompiles.
// sha256=d41be6b6eae093ae930c8d940894aa8bf279164aa0e7fc54c7ffc439fcc9e5f5; lines 253-255.
// Oracle: ((((1 + 2)))) is 3.
// Extra: ((((0)))) empty default 0; extra parens around 1 stay 1.
// DefaultSafe. Source owns locals.

void Test()
{
	int X = ((((1 + 2))));
}

int Observe_DeepParens_OnePlusTwo()
{
	int X = ((((1 + 2))));
	return X;
}

int Observe_DeepParens_EmptyZero()
{
	int X = ((((0))));
	return X;
}

int Observe_DeepParens_SingleOneBoundary()
{
	int X = ((((1))));
	return X;
}
