// Theme: Language.Syntax.EdgeCases. Positive float vs double signatures with discriminators.
// C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionOverloading
// sha256=ace5b036f383a62c834cbb82125be0cc8cd883a11c734fe4b5aea7f4a46a92cc; lines 433-453.
// Oracle: ProcessFloat(4,true)=41; ProcessDouble(4,2)=42; ReturnFloatByPrecision(10,true)~=11;
// ReturnDoubleByPrecision(10,2)~=12. Extra: false float path returns -1. DefaultSafe.

int ProcessFloat(float X, bool bUseFloatPath)
{
	return bUseFloatPath ? int(X * 10.0f) + 1 : -1;
}

int ProcessDouble(double X, int Bias)
{
	return int(X * 10.0) + Bias;
}

float ReturnFloatByPrecision(float X, bool bUseFloatPath)
{
	return bUseFloatPath ? X + 1.0f : -1.0f;
}

double ReturnDoubleByPrecision(double X, int Bias)
{
	return X + double(Bias);
}

bool Observe_ProcessFloat_Nominal()
{
	return ProcessFloat(4.0f, true) == 41 && ProcessDouble(4.0, 2) == 42 && Math::IsNearlyEqual(ReturnFloatByPrecision(10.0f, true), 11.0, 0.001) && Math::IsNearlyEqual(ReturnDoubleByPrecision(10.0, 2), 12.0, 0.001);
}

bool Observe_ProcessFloat_FalsePathBoundary()
{
	return ProcessFloat(4.0f, false) == -1 && Math::IsNearlyEqual(ReturnFloatByPrecision(10.0f, false), -1.0, 0.001);
}

bool Observe_ProcessDouble_ZeroBias()
{
	return ProcessDouble(0.0, 0) == 0 && Math::IsNearlyEqual(ReturnDoubleByPrecision(0.0, 0), 0.0, 0.001);
}
