// Theme: Gameplay.FTransform. WorldStory TArray/TMap container properties.
// C++: AngelscriptCoverageFTransformPropertyTests.cpp::FTransformContainerProperties
// Oracle after BeginPlay: TransformArray Num 3; [0].Translation.X 100;
// [0].Y 0; [1].Y 200; [2].Z 300. IntToTransformMap Num 3; [1].X 10; [2].Y 20;
// [3].Z 30. Extra: empty containers before BeginPlay. FixtureIsolated.
// Keep UPROPERTY names.

UCLASS()
class ACoverageFTransformContainerActor : AActor
{
	UPROPERTY()
	TArray<FTransform> TransformArray;

	UPROPERTY()
	TMap<int, FTransform> IntToTransformMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TransformArray.Add(FTransform(FVector(100, 0, 0)));
		TransformArray.Add(FTransform(FVector(0, 200, 0)));
		TransformArray.Add(FTransform(FVector(0, 0, 300)));

		IntToTransformMap.Add(1, FTransform(FVector(10, 0, 0)));
		IntToTransformMap.Add(2, FTransform(FVector(0, 20, 0)));
		IntToTransformMap.Add(3, FTransform(FVector(0, 0, 30)));
	}
}

bool Observe_TransformContainers_DefaultEmpty(ACoverageFTransformContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformContainerProperties setup: required Actor is null");
	}
	return Actor.TransformArray.Num() == 0
		&& Actor.IntToTransformMap.Num() == 0;
}

bool Observe_TransformArray_AfterBeginPlay(ACoverageFTransformContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.TransformArray.Num() == 3
		&& Actor.TransformArray[0].GetLocation().X == 100.0
		&& Actor.TransformArray[0].GetLocation().Y == 0.0
		&& Actor.TransformArray[1].GetLocation().Y == 200.0
		&& Actor.TransformArray[2].GetLocation().Z == 300.0;
}

bool Observe_IntToTransformMap_AfterBeginPlay(ACoverageFTransformContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.IntToTransformMap.Num() == 3
		&& Actor.IntToTransformMap[1].GetLocation().X == 10.0
		&& Actor.IntToTransformMap[2].GetLocation().Y == 20.0
		&& Actor.IntToTransformMap[3].GetLocation().Z == 30.0;
}

bool Observe_TransformContainers_CopyIndependence(ACoverageFTransformContainerActor First, ACoverageFTransformContainerActor Second)
{
	if (First is null)
	{
		throw("Test_FTransformContainerProperties setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FTransformContainerProperties setup: required Second is null");
	}
	First.BeginPlay();
	return First.TransformArray.Num() == 3
		&& Second.TransformArray.Num() == 0
		&& Second.IntToTransformMap.Num() == 0;
}
