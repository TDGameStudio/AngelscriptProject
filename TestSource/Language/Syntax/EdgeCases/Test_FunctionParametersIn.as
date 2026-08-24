// Theme: Language.Syntax.EdgeCases. Positive bool &in parameter.
// C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionParametersIn
// sha256=4d90f53504f13be4e4f008f68f6bc7b0c90c5e890cbb99a8187dcd1332afc80e; lines 83-88.
// Oracle: PassThrough(true) is true. Extra: PassThrough(false) is false.
// DefaultSafe.

bool PassThrough(bool&in b)
{
	return b;
}

bool Observe_PassThrough_Nominal()
{
	bool Value = true;
	return PassThrough(Value) == true;
}

bool Observe_PassThrough_FalseBoundary()
{
	bool Value = false;
	return PassThrough(Value) == false;
}
