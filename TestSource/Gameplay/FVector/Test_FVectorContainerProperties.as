// Theme: Gameplay.FVector. WorldStory TArray/TMap container properties.
// C++: AngelscriptCoverageFVectorPropertyTests.cpp::FVectorContainerProperties
// Oracle after BeginPlay: VectorArray Num 3; [0].X 1; [0].Y 0; [1].Y 1; [2].Z 1.
// IntToVectorMap Num 3; [1].X 1 ForwardVector; [3].Z 1 UpVector.
// Extra: empty containers before BeginPlay. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFVectorContainerActor : AActor
{
	UPROPERTY()
	TArray<FVector> VectorArray;

	UPROPERTY()
	TMap<int, FVector> IntToVectorMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		VectorArray.Add(FVector(1, 0, 0));
		VectorArray.Add(FVector(0, 1, 0));
		VectorArray.Add(FVector(0, 0, 1));

		IntToVectorMap.Add(1, FVector::ForwardVector);
		IntToVectorMap.Add(2, FVector::RightVector);
		IntToVectorMap.Add(3, FVector::UpVector);
	}
}

bool Observe_VectorContainers_DefaultEmpty(ACoverageFVectorContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorContainerProperties setup: required Actor is null");
	}
	return Actor.VectorArray.Num() == 0 && Actor.IntToVectorMap.Num() == 0;
}

bool Observe_VectorArray_AfterBeginPlay(ACoverageFVectorContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.VectorArray.Num() == 3
		&& Actor.VectorArray[0].X == 1.0
		&& Actor.VectorArray[0].Y == 0.0
		&& Actor.VectorArray[1].Y == 1.0
		&& Actor.VectorArray[2].Z == 1.0;
}

bool Observe_IntToVectorMap_AfterBeginPlay(ACoverageFVectorContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.IntToVectorMap.Num() == 3
		&& Actor.IntToVectorMap[1].X == 1.0
		&& Actor.IntToVectorMap[3].Z == 1.0;
}

bool Observe_VectorContainers_CopyIndependence(ACoverageFVectorContainerActor First, ACoverageFVectorContainerActor Second)
{
	if (First is null)
	{
		throw("Test_FVectorContainerProperties setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FVectorContainerProperties setup: required Second is null");
	}
	First.BeginPlay();
	return First.VectorArray.Num() == 3 && Second.VectorArray.Num() == 0;
}
