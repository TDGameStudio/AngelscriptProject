// Theme: Gameplay.FRotator. Positive Normalize / Clamp / IsZero oracles.
// C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorNormalizationMethods
// Oracle: GetNormalized (400,720,-400) Equals (40,0,-40); Clamp Equals native Clamp;
// IsZero true; IsNearlyZero true.
// Extra: default IsZero; (10,20,30) IsZero false. DefaultSafe.

FRotator NormalizeRotator()
{
	FRotator r = FRotator(400, 720, -400);
	return r.GetNormalized();
}

FRotator ClampRotator()
{
	FRotator r = FRotator(100, 200, 100);
	return r.Clamp();
}

bool IsZero()
{
	FRotator r = FRotator::ZeroRotator;
	return r.IsZero();
}

bool IsNearlyZero()
{
	FRotator r = FRotator(0.000001, 0.000001, 0.000001);
	return r.IsNearlyZero();
}

bool Observe_NormalizeRotator()
{
	return NormalizeRotator().Equals(FRotator(40, 0, -40), 0.001);
}

bool Observe_ClampRotator()
{
	return ClampRotator().Equals(FRotator(100, 200, 100).Clamp(), 0.001);
}

bool Observe_IsZero()
{
	return IsZero() == true;
}

bool Observe_IsNearlyZero()
{
	return IsNearlyZero() == true;
}

bool Observe_IsZero_DefaultEmpty()
{
	return FRotator().IsZero() == true;
}

bool Observe_IsZero_NonZeroBoundary()
{
	return FRotator(10, 20, 30).IsZero() == false;
}
