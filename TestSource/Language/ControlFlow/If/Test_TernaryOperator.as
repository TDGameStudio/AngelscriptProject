// Theme: Language.ControlFlow.If. Positive value oracle from TernaryOperator.
// C++: AngelscriptCoverageConditionalTests.cpp::TernaryOperator
// sha256=460e8df5c18b314067cee10a3ed9728d3b0603696b0e65eba7d1a218b5cf8342; lines 361-387.
// Oracle: BasicTernary(true) 10; NestedTernary(5) 1; ReturnTernary(true) 1; TernaryExpressions(20, 10) 30.
// Extra: false/zero/negative arms; A<=B subtracts.
// DefaultSafe. Source owns locals.

int BasicTernary(bool Condition)
{
	int X = Condition ? 10 : 20;
	return X;
}

int NestedTernary(int Value)
{
	int X = Value > 0 ? 1 : (Value < 0 ? -1 : 0);
	return X;
}

int ReturnTernary(bool Flag)
{
	return Flag ? 1 : 0;
}

int TernaryExpressions(int A, int B)
{
	return (A > B) ? (A + B) : (A - B);
}

bool Observe_TernaryOperator_Nominal()
{
	return BasicTernary(true) == 10
		&& NestedTernary(5) == 1
		&& ReturnTernary(true) == 1
		&& TernaryExpressions(20, 10) == 30;
}

bool Observe_TernaryOperator_FalseDefault()
{
	return BasicTernary(false) == 20
		&& NestedTernary(0) == 0
		&& ReturnTernary(false) == 0
		&& TernaryExpressions(10, 20) == -10;
}

bool Observe_TernaryOperator_NegativeBoundary()
{
	return NestedTernary(-3) == -1 && TernaryExpressions(7, 7) == 0;
}
