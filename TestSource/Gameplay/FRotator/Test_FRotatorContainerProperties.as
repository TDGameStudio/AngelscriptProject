// Theme: Gameplay.FRotator. WorldStory TArray/TMap FRotator after BeginPlay.
// C++: AngelscriptCoverageFRotatorPropertyTests.cpp::FRotatorContainerProperties
// Oracle: RotatorArray Num 3; [0].Pitch 0; [1].Pitch 90; [2].Yaw 180;
// IntToRotatorMap Num 3; [1].Pitch 45; [2].Yaw 90; [3].Roll 45.
// Extra: empty containers before BeginPlay. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFRotatorContainerActor : AActor
{
	UPROPERTY()
	TArray<FRotator> RotatorArray;

	UPROPERTY()
	TMap<int, FRotator> IntToRotatorMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		RotatorArray.Add(FRotator(0, 0, 0));
		RotatorArray.Add(FRotator(90, 0, 0));
		RotatorArray.Add(FRotator(0, 180, 0));

		IntToRotatorMap.Add(1, FRotator(45, 0, 0));
		IntToRotatorMap.Add(2, FRotator(0, 90, 0));
		IntToRotatorMap.Add(3, FRotator(0, 0, 45));
	}
}

bool Observe_Containers_DefaultEmpty(ACoverageFRotatorContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorContainerProperties setup: required Actor is null");
	}
	return Actor.RotatorArray.Num() == 0 && Actor.IntToRotatorMap.Num() == 0;
}

bool Observe_RotatorArray_AfterBeginPlay(ACoverageFRotatorContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.RotatorArray.Num() == 3
		&& Actor.RotatorArray[0].Pitch == 0.0
		&& Actor.RotatorArray[1].Pitch == 90.0
		&& Actor.RotatorArray[2].Yaw == 180.0;
}

bool Observe_IntToRotatorMap_AfterBeginPlay(ACoverageFRotatorContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	return Actor.IntToRotatorMap.Num() == 3
		&& Actor.IntToRotatorMap[1].Pitch == 45.0
		&& Actor.IntToRotatorMap[2].Yaw == 90.0
		&& Actor.IntToRotatorMap[3].Roll == 45.0;
}

bool Observe_RotatorArray_CopyIndependence(ACoverageFRotatorContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorContainerProperties setup: required Actor is null");
	}
	Actor.BeginPlay();
	FRotator Copy = Actor.RotatorArray[1];
	Copy.Pitch = 0.0;
	return Actor.RotatorArray[1] == FRotator(90, 0, 0);
}
