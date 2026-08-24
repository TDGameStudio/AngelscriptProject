// Theme: Language.ControlFlow.Jump. Positive value oracle from Return_Mixed.
// C++: AngelscriptSyntaxControlFlowTests.cpp::Return_Mixed
// sha256=a8ea713975bdfe2f8ca86f71c9d4fc17684aabba7cc88c1dc724976514d1631c; lines 576-578.
// Oracle: C++ disables AssertFailsToCompile (#as-engine-behavior implicit-conversion-permissive);
// float 3.14f is accepted as an int return and truncates to 3.
// Extra: truncated result is not 0 and not the untruncated 3.14.
// DefaultSafe. Source owns locals.

int Test()
{
	return 3.14f;
}

bool Observe_ReturnFloatAsInt_Nominal()
{
	return Test() == 3;
}

bool Observe_ReturnFloatAsInt_NotZeroDefault()
{
	return Test() != 0;
}
