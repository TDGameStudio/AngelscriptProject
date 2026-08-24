// Theme: Language.Syntax.EdgeCases. Positive bool default parameters.
// C++: AngelscriptCoverageBoolFunctionTests.cpp::FunctionDefaultParameters
// sha256=05e642a8f87e3019a0c9a32e05101c120063fad8231421f1e893818ab71f9280; lines 239-259.
// Oracle: CallDefaultTrue is true; CallDefaultFalse is false; EchoDefaultTrue(false)
// overrides the default. Extra: EchoDefaultFalse(true) overrides false.
// DefaultSafe.

bool EchoDefaultTrue(bool b = true)
{
	return b;
}

bool EchoDefaultFalse(bool b = false)
{
	return b;
}

bool CallDefaultTrue()
{
	return EchoDefaultTrue();
}

bool CallDefaultFalse()
{
	return EchoDefaultFalse();
}

bool Observe_BoolDefaults_Nominal()
{
	return CallDefaultTrue() == true && CallDefaultFalse() == false;
}

bool Observe_BoolDefaults_OverrideBoundary()
{
	return EchoDefaultTrue(false) == false && EchoDefaultFalse(true) == true;
}
