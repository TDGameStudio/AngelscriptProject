// Theme: Language.Syntax.EdgeCases. Positive float/double value parameters.
// C++: AngelscriptCoverageFloatFunctionTests.cpp::FunctionParametersValue
// sha256=707311a71c95c293e638ce01ac45ad467a2bfc092a876995d414f1392b7285b6; lines 43-53.
// Oracle: AcceptFloat(10.5) ~= 12.0; AcceptDouble(20.5) ~= 23.0.
// Extra: zero input uses only the addend; negative input stays negative plus addend.
// DefaultSafe. Value parameters copy; callers keep their originals.

float AcceptFloat(float X)
{
	return X + 1.5f;
}

double AcceptDouble(double X)
{
	return X + 2.5;
}

bool Observe_AcceptFloat_Nominal()
{
	return Math::IsNearlyEqual(AcceptFloat(10.5f), 12.0, 0.001) && Math::IsNearlyEqual(AcceptDouble(20.5), 23.0, 0.001);
}

bool Observe_AcceptFloat_ZeroDefault()
{
	return Math::IsNearlyEqual(AcceptFloat(0.0f), 1.5, 0.001) && Math::IsNearlyEqual(AcceptDouble(0.0), 2.5, 0.001);
}

bool Observe_AcceptFloat_NegativeBoundary()
{
	return Math::IsNearlyEqual(AcceptFloat(-1.5f), 0.0, 0.001) && Math::IsNearlyEqual(AcceptDouble(-2.5), 0.0, 0.001);
}
