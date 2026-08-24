// Theme: Gameplay.FTransform. Positive TransformPosition / TransformVector oracles.
// C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformPositionAndVector
// Oracle: native TransformPosition (10,0,0) under (100,0,0);
// TransformVector of (10,0,0) under scale 2;
// TransformPosition with scale (10,20,30)->native; TransformVector ignores translation.
// Extra: Identity TransformPosition of Zero; copy independence of Point. DefaultSafe.

FVector TransformPosition()
{
	FTransform T = FTransform(FVector(100, 0, 0));
	FVector Point = FVector(10, 0, 0);
	return T.TransformPosition(Point);
}

FVector TransformVector()
{
	FTransform T = FTransform(FQuat::Identity, FVector(100, 0, 0), FVector(2, 2, 2));
	FVector Vec = FVector(10, 0, 0);
	return T.TransformVector(Vec);
}

FVector TransformPositionWithScale()
{
	FTransform T = FTransform(FQuat::Identity, FVector(50, 50, 50), FVector(2, 2, 2));
	FVector Point = FVector(10, 20, 30);
	return T.TransformPosition(Point);
}

FVector TransformVectorNoTranslation()
{
	FTransform T = FTransform(FVector(1000, 1000, 1000));
	FVector Vec = FVector(1, 0, 0);
	return T.TransformVector(Vec);
}

bool Observe_TransformPosition()
{
	FTransform T = FTransform(FVector(100, 0, 0));
	return TransformPosition().Equals(T.TransformPosition(FVector(10, 0, 0)), 0.001);
}

bool Observe_TransformVector()
{
	FTransform T = FTransform(FQuat::Identity, FVector(100, 0, 0), FVector(2, 2, 2));
	return TransformVector().Equals(T.TransformVector(FVector(10, 0, 0)), 0.001);
}

bool Observe_TransformPositionWithScale()
{
	FTransform T = FTransform(FQuat::Identity, FVector(50, 50, 50), FVector(2, 2, 2));
	return TransformPositionWithScale().Equals(T.TransformPosition(FVector(10, 20, 30)), 0.001);
}

bool Observe_TransformVectorNoTranslation()
{
	FTransform T = FTransform(FVector(1000, 1000, 1000));
	return TransformVectorNoTranslation().Equals(T.TransformVector(FVector(1, 0, 0)), 0.001);
}

bool Observe_TransformPosition_DefaultIdentity()
{
	return FTransform().TransformPosition(FVector::ZeroVector).Equals(FVector::ZeroVector, 0.001);
}

bool Observe_TransformPosition_CopyIndependence()
{
	FVector Point = FVector(10, 0, 0);
	FTransform T = FTransform(FVector(100, 0, 0));
	FVector World = T.TransformPosition(Point);
	World.X = 0.0;
	return Point.Equals(FVector(10, 0, 0));
}
