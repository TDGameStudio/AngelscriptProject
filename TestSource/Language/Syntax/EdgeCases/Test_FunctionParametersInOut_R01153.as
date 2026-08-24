// Theme: Language.Syntax.EdgeCases. Positive float/double &inout square.
// C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionParametersInOut
// sha256=72928376ba3334b6ad42a3acccef7f749471e06aa345b220a62e02a01befdc2a; lines 245-255.
// Oracle: SquareFloat(5) -> 25; SquareDouble(10) -> 100. Extra: zero stays 0; -5 squares to 25.
// DefaultSafe. &inout mutates the caller's storage.

void SquareFloat(float&inout X)
{
	X = X * X;
}

void SquareDouble(double&inout X)
{
	X = X * X;
}

bool Observe_SquareFloat_Nominal()
{
	float F = 5.0f;
	double D = 10.0;
	SquareFloat(F);
	SquareDouble(D);
	return Math::IsNearlyEqual(F, 25.0, 0.001) && Math::IsNearlyEqual(D, 100.0, 0.001);
}

bool Observe_SquareFloat_ZeroDefault()
{
	float F = 0.0f;
	double D = 0.0;
	SquareFloat(F);
	SquareDouble(D);
	return Math::IsNearlyEqual(F, 0.0, 0.001) && Math::IsNearlyEqual(D, 0.0, 0.001);
}

bool Observe_SquareFloat_NegativeBoundary()
{
	float F = -5.0f;
	SquareFloat(F);
	return Math::IsNearlyEqual(F, 25.0, 0.001);
}
