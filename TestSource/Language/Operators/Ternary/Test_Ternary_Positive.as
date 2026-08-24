// Theme: Language.Operators.Ternary. Positive value oracle.
// C++: AngelscriptSyntaxOperatorsTests.cpp::Ternary_Positive ExpectGlobalInts
// lines 565-570;
// sha256=a466a71fd0190fb2bebc8cf6b48eabdc288a342224c8a6d2df357bfb6abed375.
// Oracle: Basic()==1; Nested()==2; WithExpr()==10; FalseCondition()==200.
// Extra: FalseCondition is the false-branch boundary; Nested's inner false
// selects 2 rather than 1 or the outer 3.
// DefaultSafe. Source owns locals.

int Basic()
{
	return true ? 1 : 0;
}

int Nested()
{
	return true ? (false ? 1 : 2) : 3;
}

int WithExpr()
{
	int A = 5;
	return (A > 3) ? A * 2 : A - 1;
}

int FalseCondition()
{
	return false ? 100 : 200;
}

bool Observe_Ternary_Nominal()
{
	return Basic() == 1 && Nested() == 2 && WithExpr() == 10 && FalseCondition() == 200;
}

bool Observe_Ternary_FalseBranchBoundary()
{
	return FalseCondition() == 200 && Nested() == 2;
}

bool Observe_Ternary_WithExprTruePath()
{
	return WithExpr() == 10;
}
