// Theme: Definitions.UEnum. WorldStory TArray/TSet/TMap of UENUM.
// C++: AngelscriptCoverageUEnumTests.cpp::UEnumInContainers
// Oracle after BeginPlay: ArraySize=3, MapSize=2, MapLookupResult=200, bSetContainsItem2=true.
// Extra: empty containers before BeginPlay; nullptr actor is the empty handle; duplicate Item2 does not grow the set.
// FixtureIsolated. Keep ArraySize/MapSize/MapLookupResult/bSetContainsItem2 names.

UENUM()
enum EContainerEnum
{
	Item1,
	Item2,
	Item3
}

UCLASS()
class ACoverageUEnumContainersActor : AActor
{
	UPROPERTY()
	TArray<EContainerEnum> EnumArray;

	UPROPERTY()
	TSet<EContainerEnum> EnumSet;

	UPROPERTY()
	TMap<EContainerEnum, int> EnumToIntMap;

	UPROPERTY()
	TMap<int, EContainerEnum> IntToEnumMap;

	UPROPERTY()
	int ArraySize = 0;

	UPROPERTY()
	int MapSize = 0;

	UPROPERTY()
	int MapLookupResult = 0;

	UPROPERTY()
	bool bSetContainsItem2 = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EnumArray.Add(EContainerEnum::Item1);
		EnumArray.Add(EContainerEnum::Item3);
		EnumArray.Add(EContainerEnum::Item2);
		ArraySize = EnumArray.Num();
		check(ArraySize == 3);
		check(EnumArray[1] == EContainerEnum::Item3);

		EnumSet.Add(EContainerEnum::Item1);
		EnumSet.Add(EContainerEnum::Item2);
		EnumSet.Add(EContainerEnum::Item2);
		check(EnumSet.Num() == 2);
		bSetContainsItem2 = EnumSet.Contains(EContainerEnum::Item2);

		EnumToIntMap.Add(EContainerEnum::Item1, 100);
		EnumToIntMap.Add(EContainerEnum::Item2, 200);
		MapSize = EnumToIntMap.Num();
		check(MapSize == 2);
		MapLookupResult = EnumToIntMap[EContainerEnum::Item2];
		check(MapLookupResult == 200);

		IntToEnumMap.Add(1, EContainerEnum::Item1);
		IntToEnumMap.Add(2, EContainerEnum::Item2);
		check(IntToEnumMap[2] == EContainerEnum::Item2);
	}
}

bool Observe_Containers_EmptyDefaults(ACoverageUEnumContainersActor Actor)
{
	return Actor.EnumArray.Num() == 0
		&& Actor.EnumSet.Num() == 0
		&& Actor.EnumToIntMap.Num() == 0
		&& Actor.IntToEnumMap.Num() == 0
		&& Actor.ArraySize == 0
		&& Actor.MapSize == 0
		&& Actor.MapLookupResult == 0
		&& !Actor.bSetContainsItem2;
}

bool Observe_Containers_BeginPlayOracle(ACoverageUEnumContainersActor Actor)
{
	Actor.BeginPlay();
	return Actor.ArraySize == 3
		&& Actor.MapSize == 2
		&& Actor.MapLookupResult == 200
		&& Actor.bSetContainsItem2
		&& Actor.EnumArray.Num() == 3
		&& Actor.EnumArray[1] == EContainerEnum::Item3;
}

bool Observe_Containers_NullDefault()
{
	ACoverageUEnumContainersActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_Containers_SetDuplicateBoundary()
{
	TSet<EContainerEnum> Isolated;
	Isolated.Add(EContainerEnum::Item2);
	Isolated.Add(EContainerEnum::Item2);
	return Isolated.Num() == 1 && Isolated.Contains(EContainerEnum::Item2);
}
