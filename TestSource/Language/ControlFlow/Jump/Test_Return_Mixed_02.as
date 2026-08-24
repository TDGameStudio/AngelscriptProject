// Theme: Language.ControlFlow.Jump. Positive value oracle from Return_Mixed.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
// sha256=d62df7436867c43ba55e7f6166a0a28ceded6b4ce9d7632f82345c50ac214292; lines 538-540.
// Oracle: Test() returns 42.
// Extra: 42 is not the default 0.
// DefaultSafe. Source owns locals.

int Test()
{
	return 42;
}

bool Observe_ReturnInt_Nominal()
{
	return Test() == 42;
}

bool Observe_ReturnInt_ZeroDefault()
{
	int Empty;
	return Empty == 0 && Test() != Empty;
}
