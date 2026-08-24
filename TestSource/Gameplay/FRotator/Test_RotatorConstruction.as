// Theme: Gameplay.FRotator. Positive construction oracles.
// C++: AngelscriptCoverageFRotatorExpressionTests.cpp::RotatorConstruction
// Oracle: default ZeroRotator; (10,20,30); ZeroRotator; (45,0,0); (0,90,0); (0,0,180).
// Extra: default empty; copy independence of three-param. DefaultSafe.

FRotator ConstructDefault()
{
	return FRotator();
}

FRotator ConstructThreeParams()
{
	return FRotator(10, 20, 30);
}

FRotator ConstructZeroRotator()
{
	return FRotator::ZeroRotator;
}

FRotator ConstructPitchOnly()
{
	return FRotator(45, 0, 0);
}

FRotator ConstructYawOnly()
{
	return FRotator(0, 90, 0);
}

FRotator ConstructRollOnly()
{
	return FRotator(0, 0, 180);
}

bool Observe_ConstructDefault()
{
	return ConstructDefault() == FRotator::ZeroRotator;
}

bool Observe_ConstructThreeParams()
{
	return ConstructThreeParams() == FRotator(10, 20, 30);
}

bool Observe_ConstructZeroRotator()
{
	return ConstructZeroRotator() == FRotator::ZeroRotator;
}

bool Observe_ConstructPitchOnly()
{
	return ConstructPitchOnly() == FRotator(45, 0, 0);
}

bool Observe_ConstructYawOnly()
{
	return ConstructYawOnly() == FRotator(0, 90, 0);
}

bool Observe_ConstructRollOnly()
{
	return ConstructRollOnly() == FRotator(0, 0, 180);
}

bool Observe_ConstructDefault_Empty()
{
	FRotator Empty = FRotator();
	return Empty.Pitch == 0.0 && Empty.Yaw == 0.0 && Empty.Roll == 0.0;
}

bool Observe_ConstructThreeParams_CopyIndependence()
{
	FRotator Original = ConstructThreeParams();
	FRotator Copy = Original;
	Copy.Pitch = 0.0;
	return Original == FRotator(10, 20, 30) && Copy.Pitch == 0.0;
}
