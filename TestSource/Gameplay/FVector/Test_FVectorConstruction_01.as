// Theme: Gameplay.FVector. Positive construction oracles.
// C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorConstruction
// Oracle: default/ZeroVector (0,0,0); three-param (1,2,3); single (5,5,5);
// OneVector (1,1,1); Forward (1,0,0); Right (0,1,0); Up (0,0,1).
// Extra: empty ZeroVector; copy independence of three-param. DefaultSafe.

FVector ConstructDefault()
{
	return FVector();
}

FVector ConstructThreeParams()
{
	return FVector(1, 2, 3);
}

FVector ConstructSingleValue()
{
	return FVector(5);
}

FVector ConstructZeroVector()
{
	return FVector::ZeroVector;
}

FVector ConstructOneVector()
{
	return FVector::OneVector;
}

FVector ConstructForwardVector()
{
	return FVector::ForwardVector;
}

FVector ConstructRightVector()
{
	return FVector::RightVector;
}

FVector ConstructUpVector()
{
	return FVector::UpVector;
}

bool Observe_ConstructDefault()
{
	return ConstructDefault().Equals(FVector::ZeroVector);
}

bool Observe_ConstructThreeParams()
{
	return ConstructThreeParams().Equals(FVector(1, 2, 3));
}

bool Observe_ConstructSingleValue()
{
	return ConstructSingleValue().Equals(FVector(5, 5, 5));
}

bool Observe_ConstructZeroVector()
{
	return ConstructZeroVector().Equals(FVector::ZeroVector);
}

bool Observe_ConstructOneVector()
{
	return ConstructOneVector().Equals(FVector::OneVector);
}

bool Observe_ConstructForwardVector()
{
	return ConstructForwardVector().Equals(FVector::ForwardVector);
}

bool Observe_ConstructRightVector()
{
	return ConstructRightVector().Equals(FVector::RightVector);
}

bool Observe_ConstructUpVector()
{
	return ConstructUpVector().Equals(FVector::UpVector);
}

bool Observe_ConstructDefault_EmptyZero()
{
	FVector Empty = FVector();
	return Empty.X == 0.0 && Empty.Y == 0.0 && Empty.Z == 0.0;
}

bool Observe_ConstructThreeParams_CopyIndependence()
{
	FVector Original = ConstructThreeParams();
	FVector Copy = Original;
	Copy.X = 0.0;
	return Original.Equals(FVector(1, 2, 3)) && Copy.X == 0.0;
}
