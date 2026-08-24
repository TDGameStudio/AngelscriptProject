// Theme: Definitions.UFunction. WorldStory const FQuat&in, TArray<FQuat> in/out, stored member.
// C++: AngelscriptCoverageFQuatFunctionTests.cpp::UFunctionConstArrayAndOutPaths
// Oracle: ReadConstQuat returns GetAngle; StoreAndReturn writes StoredQuat and returns Inverse; AcceptQuatArray count 2.
// Extra: empty TArray count 0; nullptr actor is the empty handle; Identity inverse is Identity.
// FixtureIsolated. Keep StoredQuat / StoredQuats / LastArrayProduct / LastArrayCount names.

UCLASS()
class ACoverageFQuatFunctionConstArrayActor : AActor
{
	UPROPERTY()
	FQuat StoredQuat = FQuat::Identity;

	UPROPERTY()
	TArray<FQuat> StoredQuats;

	UPROPERTY()
	FQuat LastArrayProduct = FQuat::Identity;

	UPROPERTY()
	int LastArrayCount = 0;

	UFUNCTION()
	double ReadConstQuat(const FQuat&in Value)
	{
		return Value.GetAngle();
	}

	UFUNCTION()
	FQuat StoreAndReturn(FQuat Value)
	{
		StoredQuat = Value;
		return StoredQuat.Inverse();
	}

	UFUNCTION()
	int AcceptQuatArray(const TArray<FQuat>&in Values)
	{
		LastArrayCount = Values.Num();
		LastArrayProduct = FQuat::Identity;
		for (FQuat Value : Values)
		{
			LastArrayProduct *= Value;
		}
		return LastArrayCount;
	}

	UFUNCTION()
	TArray<FQuat> MakeQuatArray(FQuat First, FQuat Second)
	{
		TArray<FQuat> Result;
		Result.Add(First);
		Result.Add(Second);
		StoredQuats = Result;
		return Result;
	}

	UFUNCTION()
	void FillOutQuatArray(TArray<FQuat>&out Result)
	{
		Result.Add(FQuat::Identity);
		Result.Add(FQuat(FVector::UpVector, 1.5707963267948966));
		StoredQuats = Result;
	}
}

bool Observe_QuatArray_EmptyCount(ACoverageFQuatFunctionConstArrayActor Actor)
{
	TArray<FQuat> Empty;
	return Actor.AcceptQuatArray(Empty) == 0 && Actor.LastArrayCount == 0 && Actor.LastArrayProduct.Equals(FQuat::Identity, 0.01);
}

bool Observe_QuatArray_IdentityInverseBoundary(ACoverageFQuatFunctionConstArrayActor Actor)
{
	FQuat Inverse = Actor.StoreAndReturn(FQuat::Identity);
	return Inverse.Equals(FQuat::Identity, 0.01) && Actor.StoredQuat.Equals(FQuat::Identity, 0.01)
		&& Math::IsNearlyEqual(Actor.ReadConstQuat(FQuat::Identity), 0.0);
}

bool Observe_QuatArray_NullDefault()
{
	ACoverageFQuatFunctionConstArrayActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_QuatArray_TwoElementProduct(ACoverageFQuatFunctionConstArrayActor Actor)
{
	FQuat First = FQuat::Identity;
	FQuat Second = FQuat(FVector::UpVector, 1.5707963267948966);
	TArray<FQuat> Made = Actor.MakeQuatArray(First, Second);
	int Count = Actor.AcceptQuatArray(Made);
	TArray<FQuat> Filled;
	Actor.FillOutQuatArray(Filled);
	return Count == 2 && Made.Num() == 2 && Filled.Num() == 2 && Actor.StoredQuats.Num() == 2;
}
