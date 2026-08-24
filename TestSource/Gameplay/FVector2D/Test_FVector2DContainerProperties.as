// Theme: Gameplay.FVector2D. WorldStory TArray/TMap container properties.
// C++: AngelscriptCoverageFVector2DPropertyTests.cpp::FVector2DContainerProperties
// Oracle after BeginPlay: VectorArray Num 3; [0] (1,0); [1].Y 1; [2] (1,1).
// IntToVectorMap Num 3; [1] (10,20); [3] ZeroVector.
// Extra: empty containers before BeginPlay. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFVector2DContainerActor : AActor
{
	UPROPERTY()
	TArray<FVector2D> VectorArray;

	UPROPERTY()
	TMap<int, FVector2D> IntToVectorMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		VectorArray.Add(FVector2D(1, 0));
		VectorArray.Add(FVector2D(0, 1));
		VectorArray.Add(FVector2D(1, 1));

		IntToVectorMap.Add(1, FVector2D(10, 20));
		IntToVectorMap.Add(2, FVector2D(30, 40));
		IntToVectorMap.Add(3, FVector2D::ZeroVector);
	}
}

bool Observe_Vector2DContainers_DefaultEmpty(ACoverageFVector2DContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DContainerProperties setup: required Actor is null");
	}
	return Actor.VectorArray.Num() == 0 && Actor.IntToVectorMap.Num() == 0;
}

bool Observe_VectorArray_AfterBeginPlay(ACoverageFVector2DContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.VectorArray.Num() == 3
		&& Actor.VectorArray[0].X == 1.0
		&& Actor.VectorArray[0].Y == 0.0
		&& Actor.VectorArray[1].Y == 1.0
		&& Actor.VectorArray[2].X == 1.0
		&& Actor.VectorArray[2].Y == 1.0;
}

bool Observe_IntToVectorMap_AfterBeginPlay(ACoverageFVector2DContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.IntToVectorMap.Num() == 3
		&& Actor.IntToVectorMap[1].X == 10.0
		&& Actor.IntToVectorMap[1].Y == 20.0
		&& Actor.IntToVectorMap[3].X == 0.0;
}

bool Observe_Vector2DContainers_CopyIndependence(ACoverageFVector2DContainerActor First, ACoverageFVector2DContainerActor Second)
{
	if (First is null)
	{
		throw("Test_FVector2DContainerProperties setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FVector2DContainerProperties setup: required Second is null");
	}
	First.BeginPlay();
	return First.VectorArray.Num() == 3 && Second.VectorArray.Num() == 0;
}
