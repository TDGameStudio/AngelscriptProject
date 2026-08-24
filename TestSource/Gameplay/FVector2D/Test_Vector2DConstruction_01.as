// Theme: Gameplay.FVector2D. Positive construction oracles.
// C++: AngelscriptCoverageFVector2DExpressionTests.cpp::Vector2DConstruction
// Oracle: default/ZeroVector (0,0); two-param (3.5,7.2); UnitVector (1,1).
// Extra: empty ZeroVector; copy independence of two-param. DefaultSafe.

FVector2D ConstructDefault()
{
	return FVector2D();
}

FVector2D ConstructTwoParams()
{
	return FVector2D(3.5, 7.2);
}

FVector2D ConstructZeroVector()
{
	return FVector2D::ZeroVector;
}

FVector2D ConstructUnitVector()
{
	return FVector2D::UnitVector;
}

bool Observe_ConstructDefault()
{
	return ConstructDefault().Equals(FVector2D::ZeroVector);
}

bool Observe_ConstructTwoParams()
{
	return ConstructTwoParams().Equals(FVector2D(3.5, 7.2));
}

bool Observe_ConstructZeroVector()
{
	return ConstructZeroVector().Equals(FVector2D::ZeroVector);
}

bool Observe_ConstructUnitVector()
{
	return ConstructUnitVector().Equals(FVector2D::UnitVector);
}

bool Observe_ConstructDefault_EmptyZero()
{
	FVector2D Empty = FVector2D();
	return Empty.X == 0.0 && Empty.Y == 0.0;
}

bool Observe_ConstructTwoParams_CopyIndependence()
{
	FVector2D Original = ConstructTwoParams();
	FVector2D Copy = Original;
	Copy.X = 0.0;
	return Original.Equals(FVector2D(3.5, 7.2)) && Copy.X == 0.0;
}
