// Theme: Language.Syntax.EdgeCases. Positive bool/int overload resolution.
// C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionOverloading
// sha256=1a4f3aa7214fe832b60afad1b28298c2bc1795c78be80757b3b10e764ce8da37; lines 298-318.
// Oracle: CallBoolOverload == 10; CallIntOverload == 105. Extra: Pick(false)
// is 20; Pick(0) is 100. DefaultSafe.

int Pick(bool b)
{
	return b ? 10 : 20;
}

int Pick(int Value)
{
	return Value + 100;
}

int CallBoolOverload()
{
	return Pick(true);
}

int CallIntOverload()
{
	return Pick(5);
}

bool Observe_Overload_Nominal()
{
	return CallBoolOverload() == 10 && CallIntOverload() == 105;
}

bool Observe_Overload_FalseAndZeroBoundary()
{
	return Pick(false) == 20 && Pick(0) == 100;
}
