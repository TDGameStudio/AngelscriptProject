// Theme: Definitions.UFunction. WorldStory FTransform compose, location, &out, TransformPosition.
// C++: AngelscriptCoverageFTransformFunctionTests.cpp::UFunctionParametersAndReturn
// Oracle: ComposeTransforms T1*T2; GetTransformLocation (50,100,150); WriteTransformOut (10,20,30); TransformPoint.
// Extra: Identity empty; nullptr actor is the empty handle.
// FixtureIsolated.

UCLASS()
class ACoverageFTransformFunctionActor : AActor
{
	UFUNCTION()
	FTransform ComposeTransforms(FTransform a, FTransform b)
	{
		return a * b;
	}

	UFUNCTION()
	FVector GetTransformLocation(FTransform t)
	{
		return t.GetLocation();
	}

	UFUNCTION()
	void WriteTransformOut(FTransform&out result)
	{
		result = FTransform(FVector(10, 20, 30));
	}

	UFUNCTION()
	FVector TransformPoint(FTransform t, FVector point)
	{
		return t.TransformPosition(point);
	}
}

bool Observe_TransformFunction_Nominal(ACoverageFTransformFunctionActor Actor)
{
	FTransform T1 = FTransform(FVector(100, 0, 0));
	FTransform T2 = FTransform(FVector(0, 100, 0));
	FTransform Composed = Actor.ComposeTransforms(T1, T2);
	FTransform OutValue = FTransform::Identity;
	Actor.WriteTransformOut(OutValue);
	FVector Located = Actor.GetTransformLocation(FTransform(FVector(50, 100, 150)));
	FVector Moved = Actor.TransformPoint(FTransform(FVector(100, 0, 0)), FVector(10, 0, 0));
	return Composed.Equals(T1 * T2, 0.01)
		&& Located.Equals(FVector(50, 100, 150), 0.01)
		&& OutValue.GetLocation().Equals(FVector(10, 20, 30), 0.01)
		&& Moved.Equals(FVector(110, 0, 0), 0.01);
}

bool Observe_TransformFunction_IdentityEmpty(ACoverageFTransformFunctionActor Actor)
{
	FTransform Identity = FTransform::Identity;
	FVector Point = FVector(3, 4, 5);
	return Actor.GetTransformLocation(Identity).Equals(FVector::ZeroVector, 0.01)
		&& Actor.TransformPoint(Identity, Point).Equals(Point, 0.01)
		&& Actor.ComposeTransforms(Identity, Identity).Equals(Identity, 0.01);
}

bool Observe_TransformFunction_NullDefault()
{
	ACoverageFTransformFunctionActor Actor = nullptr;
	return Actor == nullptr;
}
