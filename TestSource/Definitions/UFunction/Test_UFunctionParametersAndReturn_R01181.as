// Theme: Definitions.UFunction. WorldStory FQuat multiply, axis, &out, rotator convert.
// C++: AngelscriptCoverageFQuatFunctionTests.cpp::UFunctionParametersAndReturn
// Oracle: MultiplyQuats(yaw45,yaw45) equals product; WriteOut FQuat(FRotator(0,90,0)); QuatToRotator yaw90.
// Extra: Identity * Identity empty; nullptr actor is the empty handle.
// FixtureIsolated.

UCLASS()
class ACoverageFQuatFunctionActor : AActor
{
	UFUNCTION()
	FQuat MultiplyQuats(FQuat a, FQuat b)
	{
		return a * b;
	}

	UFUNCTION()
	FVector QuatToAxisX(FQuat q)
	{
		return q.GetAxisX();
	}

	UFUNCTION()
	void WriteOut(FQuat&out result)
	{
		result = FQuat(FRotator(0, 90, 0));
	}

	UFUNCTION()
	FRotator QuatToRotator(FQuat q)
	{
		return q.Rotator();
	}
}

bool Observe_QuatFunction_Nominal(ACoverageFQuatFunctionActor Actor)
{
	FQuat A = FQuat(FRotator(0, 45, 0));
	FQuat B = FQuat(FRotator(0, 45, 0));
	FQuat Product = Actor.MultiplyQuats(A, B);
	FQuat OutValue = FQuat::Identity;
	Actor.WriteOut(OutValue);
	FQuat Yaw90 = FQuat(FRotator(0, 90, 0));
	return Product.Equals(A * B, 0.01)
		&& OutValue.Equals(Yaw90, 0.01)
		&& Actor.QuatToRotator(Yaw90).Equals(FRotator(0, 90, 0), 0.1);
}

bool Observe_QuatFunction_IdentityEmpty(ACoverageFQuatFunctionActor Actor)
{
	FQuat Product = Actor.MultiplyQuats(FQuat::Identity, FQuat::Identity);
	return Product.Equals(FQuat::Identity, 0.01)
		&& Actor.QuatToAxisX(FQuat::Identity).Equals(FVector(1, 0, 0), 0.01);
}

bool Observe_QuatFunction_NullDefault()
{
	ACoverageFQuatFunctionActor Actor = nullptr;
	return Actor == nullptr;
}
