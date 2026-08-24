// Theme: Language.Syntax.EdgeCases. Positive bool &inout parameter.
// C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionParametersInOut
// sha256=4141d8f2adf3cf8f6345ef338649eec457d4e5f309432f7cce6a79e1be02cb98; lines 171-176.
// Oracle: Toggle(true) writes false. Extra: Toggle(false) writes true.
// DefaultSafe.

void Toggle(bool&inout b)
{
	b = !b;
}

bool Observe_Toggle_Nominal()
{
	bool Value = true;
	Toggle(Value);
	return Value == false;
}

bool Observe_Toggle_FalseBoundary()
{
	bool Value = false;
	Toggle(Value);
	return Value == true;
}
