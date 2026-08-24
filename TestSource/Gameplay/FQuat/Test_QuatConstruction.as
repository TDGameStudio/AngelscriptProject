// Theme: Gameplay.FQuat. Positive construction oracles.
// C++: AngelscriptCoverageFQuatExpressionTests.cpp::QuatConstruction
// Oracle: default Identity; four-param (0,0,0,1); Identity; from FRotator(0,90,0);
// from UpVector / 1.5708.
// Extra: default empty Identity; copy independence of four-param. DefaultSafe.

FQuat ConstructDefault()
{
	return FQuat();
}

FQuat ConstructFourParams()
{
	return FQuat(0, 0, 0, 1);
}

FQuat ConstructIdentity()
{
	return FQuat::Identity;
}

FQuat ConstructFromRotator()
{
	return FQuat(FRotator(0, 90, 0));
}

FQuat ConstructFromAxisAngle()
{
	FVector axis = FVector::UpVector;
	float angleRad = 1.5708; // 90 degrees in radians
	return FQuat(axis, angleRad);
}

bool Observe_ConstructDefault()
{
	return ConstructDefault().Equals(FQuat::Identity, 0.001);
}

bool Observe_ConstructFourParams()
{
	return ConstructFourParams().Equals(FQuat(0, 0, 0, 1), 0.001);
}

bool Observe_ConstructIdentity()
{
	return ConstructIdentity().Equals(FQuat::Identity, 0.001);
}

bool Observe_ConstructFromRotator()
{
	return ConstructFromRotator().Equals(FQuat(FRotator(0, 90, 0)), 0.01);
}

bool Observe_ConstructFromAxisAngle()
{
	return ConstructFromAxisAngle().Equals(FQuat(FVector::UpVector, 1.5708), 0.01);
}

bool Observe_ConstructDefault_EmptyIsIdentity()
{
	FQuat Empty = FQuat();
	return Empty == FQuat::Identity;
}

bool Observe_ConstructFourParams_CopyIndependence()
{
	FQuat Original = ConstructFourParams();
	FQuat Copy = Original;
	Copy.X = 0.5;
	return Original.Equals(FQuat(0, 0, 0, 1), 0.001) && Copy.X == 0.5;
}
