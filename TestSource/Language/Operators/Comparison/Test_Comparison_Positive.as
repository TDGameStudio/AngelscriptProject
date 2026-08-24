// Theme: Language.Operators.Comparison. Positive value oracle from Comparison_Positive.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Comparison_Positive
// sha256=b708bfe2855b0d7c4671dc503affcf9c59e0d24a7b1ca9f42bfe9718ab7ffd70; lines 367-376.
// Oracle: Equal 1; NotEqual 1; LessThan 1; GreaterThan 1; LessEqual 1; GreaterEqual 1;
// ChainedCmp 1; FloatCompare 1.
// Extra: 1==2 and 2<1 are the false boundary; 1.0f>1.5f is the inverse float compare.
// DefaultSafe. Source owns locals.

int Equal()
{
	return (1 == 1) ? 1 : 0;
}

int NotEqual()
{
	return (1 != 2) ? 1 : 0;
}

int LessThan()
{
	return (1 < 2) ? 1 : 0;
}

int GreaterThan()
{
	return (2 > 1) ? 1 : 0;
}

int LessEqual()
{
	return (1 <= 1) ? 1 : 0;
}

int GreaterEqual()
{
	return (2 >= 1) ? 1 : 0;
}

int ChainedCmp()
{
	int A = 1;
	int B = 2;
	int C = 3;
	return ((A < B) && (B < C)) ? 1 : 0;
}

int FloatCompare()
{
	return (1.5f > 1.0f) ? 1 : 0;
}

bool Observe_Comparison_Nominal()
{
	return Equal() == 1
		&& NotEqual() == 1
		&& LessThan() == 1
		&& GreaterThan() == 1
		&& LessEqual() == 1
		&& GreaterEqual() == 1
		&& ChainedCmp() == 1
		&& FloatCompare() == 1;
}

bool Observe_Comparison_FalseBoundary()
{
	return ((1 == 2) ? 1 : 0) == 0 && ((2 < 1) ? 1 : 0) == 0;
}

bool Observe_Comparison_FloatInverseBoundary()
{
	return ((1.5f > 1.0f) ? 1 : 0) == FloatCompare() && ((1.0f > 1.5f) ? 1 : 0) == 0;
}
