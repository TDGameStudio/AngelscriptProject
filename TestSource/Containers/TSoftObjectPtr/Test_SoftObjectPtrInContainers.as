// Theme: Containers.TSoftObjectPtr. WorldStory: TArray/TMap of TSoftObjectPtr.
// C++: AngelscriptCoverageSoftReferenceTests.cpp::SoftObjectPtrInContainers
// CompileScriptModule + spawn + BeginPlay. Oracle: ArrayWorked and MapWorked true.
// Extra: local construct leaves both containers empty; copies do not share elements.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageSoftRefContainersActor : AActor
{
	UPROPERTY()
	TArray<TSoftObjectPtr<AActor>> SoftActorArray;

	UPROPERTY()
	TMap<int, TSoftObjectPtr<AActor>> SoftActorMap;

	UPROPERTY()
	bool ArrayWorked = false;

	UPROPERTY()
	bool MapWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test TArray with soft references
		AActor Actor1 = SpawnActor(AActor::StaticClass());
		AActor Actor2 = SpawnActor(AActor::StaticClass());

		TSoftObjectPtr<AActor> Soft1 = Actor1;
		TSoftObjectPtr<AActor> Soft2 = Actor2;

		SoftActorArray.Add(Soft1);
		SoftActorArray.Add(Soft2);

		if (SoftActorArray.Num() == 2 &&
			SoftActorArray[0].IsValid() &&
			SoftActorArray[1].IsValid())
		{
			ArrayWorked = true;
		}

		// Test TMap with soft references
		SoftActorMap.Add(1, Soft1);
		SoftActorMap.Add(2, Soft2);

		if (SoftActorMap.Num() == 2 &&
			SoftActorMap[1].IsValid() &&
			SoftActorMap[2].IsValid())
		{
			MapWorked = true;
		}
	}
}

bool Observe_SoftRefContainers_DefaultEmpty(ACoverageSoftRefContainersActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftObjectPtrInContainers setup: required Actor is null");
	}
	return Actor.SoftActorArray.Num() == 0
		&& Actor.SoftActorMap.Num() == 0
		&& Actor.ArrayWorked == false
		&& Actor.MapWorked == false;
}

bool Observe_SoftRefContainers_CopyIndependence(ACoverageSoftRefContainersActor First, ACoverageSoftRefContainersActor Second)
{
	if (First is null)
	{
		throw("Test_SoftObjectPtrInContainers setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SoftObjectPtrInContainers setup: required Second is null");
	}
	TSoftObjectPtr<AActor> Empty;
	First.SoftActorArray.Add(Empty);
	First.SoftActorMap.Add(1, Empty);
	return First.SoftActorArray.Num() == 1
		&& First.SoftActorMap.Num() == 1
		&& Second.SoftActorArray.Num() == 0
		&& Second.SoftActorMap.Num() == 0;
}
