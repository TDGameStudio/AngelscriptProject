// Theme: Language.ControlFlow.Jump. Positive value oracle from Return_Mixed.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
// sha256=8cd8d78bed43284cddcea34dece420a5f94797e377da1696c7fbb7e43666fd65; lines 545-547.
// Oracle: Test() returns X * 2 + 1 == 11.
// Extra: expression is not the unmultiplied 5.
// DefaultSafe. Source owns locals.

int Test()
{
	int X = 5;
	return X * 2 + 1;
}

bool Observe_ReturnExpression_Nominal()
{
	return Test() == 11;
}

bool Observe_ReturnExpression_NotBareX()
{
	return Test() != 5 && Test() != 10;
}
