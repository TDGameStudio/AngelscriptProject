// Theme: Language.Syntax.EdgeCases. Positive float/double default arguments.
// C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionDefaultParameters
// sha256=5d8c3a3799ae1bbb9e33ea0457cb9a387828470384df95060a8a85710dcab5bd; lines 351-371.
// Oracle: AddFloatDefaultImplicit(10) ~= 11.5; AddFloatDefault(10,4) ~= 14.0;
// AddDoubleDefaultImplicit(20) ~= 22.5; AddDoubleDefault(20,5) ~= 25.0.
// Extra: zero + default uses only the f-suffix / double literal. DefaultSafe.

float AddFloatDefault(float X, float Y = 1.5f)
{
	return X + Y;
}

double AddDoubleDefault(double X, double Y = 2.5)
{
	return X + Y;
}

float AddFloatDefaultImplicit(float X)
{
	return AddFloatDefault(X);
}

double AddDoubleDefaultImplicit(double X)
{
	return AddDoubleDefault(X);
}

bool Observe_AddFloatDefault_Nominal()
{
	return Math::IsNearlyEqual(AddFloatDefaultImplicit(10.0f), 11.5, 0.001) && Math::IsNearlyEqual(AddFloatDefault(10.0f, 4.0f), 14.0, 0.001) && Math::IsNearlyEqual(AddDoubleDefaultImplicit(20.0), 22.5, 0.001) && Math::IsNearlyEqual(AddDoubleDefault(20.0, 5.0), 25.0, 0.001);
}

bool Observe_AddFloatDefault_ZeroPlusDefault()
{
	return Math::IsNearlyEqual(AddFloatDefaultImplicit(0.0f), 1.5, 0.001) && Math::IsNearlyEqual(AddDoubleDefaultImplicit(0.0), 2.5, 0.001);
}

bool Observe_AddFloatDefault_ExplicitOverrideBoundary()
{
	return Math::IsNearlyEqual(AddFloatDefault(10.0f, 0.0f), 10.0, 0.001) && Math::IsNearlyEqual(AddDoubleDefault(20.0, 0.0), 20.0, 0.001);
}
