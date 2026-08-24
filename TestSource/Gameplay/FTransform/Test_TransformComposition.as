// Theme: Gameplay.FTransform. Positive composition * oracles.
// C++: AngelscriptCoverageFTransformExpressionTests.cpp::TransformComposition
// Oracle: T1*T2 native; scale*translation native; three-transform product native.
// Extra: Identity * Identity; copy independence of T1. DefaultSafe.

FTransform ComposeTransforms()
{
	FTransform T1 = FTransform(FVector(100, 0, 0));
	FTransform T2 = FTransform(FVector(0, 200, 0));
	return T1 * T2;
}

FTransform ComposeWithScale()
{
	FTransform T1 = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 2, 2));
	FTransform T2 = FTransform(FVector(10, 10, 10));
	return T1 * T2;
}

FTransform ComposeThree()
{
	FTransform T1 = FTransform(FVector(100, 0, 0));
	FTransform T2 = FTransform(FVector(0, 100, 0));
	FTransform T3 = FTransform(FVector(0, 0, 100));
	return T1 * T2 * T3;
}

bool Observe_ComposeTransforms()
{
	FTransform T1 = FTransform(FVector(100, 0, 0));
	FTransform T2 = FTransform(FVector(0, 200, 0));
	return ComposeTransforms().Equals(T1 * T2, 0.001);
}

bool Observe_ComposeWithScale()
{
	FTransform T1 = FTransform(FQuat::Identity, FVector::ZeroVector, FVector(2, 2, 2));
	FTransform T2 = FTransform(FVector(10, 10, 10));
	return ComposeWithScale().Equals(T1 * T2, 0.001);
}

bool Observe_ComposeThree()
{
	FTransform T1 = FTransform(FVector(100, 0, 0));
	FTransform T2 = FTransform(FVector(0, 100, 0));
	FTransform T3 = FTransform(FVector(0, 0, 100));
	return ComposeThree().Equals(T1 * T2 * T3, 0.001);
}

bool Observe_ComposeTransforms_DefaultIdentity()
{
	return (FTransform() * FTransform::Identity).Equals(FTransform::Identity, 0.001);
}

bool Observe_ComposeTransforms_CopyIndependence()
{
	FTransform T1 = FTransform(FVector(100, 0, 0));
	FTransform T2 = FTransform(FVector(0, 200, 0));
	FTransform Product = T1 * T2;
	Product.SetLocation(FVector::ZeroVector);
	return T1.GetLocation().Equals(FVector(100, 0, 0), 0.001)
		&& T2.GetLocation().Equals(FVector(0, 200, 0), 0.001);
}
