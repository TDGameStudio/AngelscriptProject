// Theme: Containers.TArray. WorldStory UFUNCTION FTransform array store/out.
// Extra: empty AcceptTransformArray LastArrayCount 0. FixtureIsolated.

UCLASS()
class ACoverageFTransformFunctionArrayActor : AActor
{
	UPROPERTY()
	FTransform StoredTransform;

	UPROPERTY()
	TArray<FTransform> StoredTransforms;

	UPROPERTY()
	int LastArrayCount = 0;

	UFUNCTION()
	FTransform StoreAndReturnInverse(FTransform Value)
	{
		StoredTransform = Value;
		return StoredTransform.Inverse();
	}

	UFUNCTION()
	int AcceptTransformArray(const TArray<FTransform>&in Values)
	{
		LastArrayCount = Values.Num();
		StoredTransform = FTransform::Identity;
		for (FTransform Value : Values)
		{
			StoredTransform *= Value;
		}
		return LastArrayCount;
	}

	UFUNCTION()
	TArray<FTransform> MakeTransformArray(FTransform First, FTransform Second)
	{
		TArray<FTransform> Result;
		Result.Add(First);
		Result.Add(Second);
		StoredTransforms = Result;
		return Result;
	}

	UFUNCTION()
	void FillOutTransformArray(TArray<FTransform>&out Result)
	{
		Result.Add(FTransform::Identity);
		Result.Add(FTransform(FQuat::Identity, FVector(30, 60, 90), FVector(2, 2, 2)));
		StoredTransforms = Result;
	}
}
