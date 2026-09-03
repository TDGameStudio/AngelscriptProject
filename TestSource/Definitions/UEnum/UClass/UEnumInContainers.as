/**
 * TArray, TSet, and TMap of a UENUM. C++ reads ArraySize, MapSize,
 * MapLookupResult, and bSetContainsItem2 by path after BeginPlay, so those names
 * are kept.
 *
 * @Theme Definitions.UEnum
 * @Subject UEnum.UEnumInContainers
 * @Harness UClass
 * @Tag Definitions.UEnum.UEnumInContainers
 * @Provenance Theme: Definitions.UEnum. WorldStory TArray/TSet/TMap of UENUM.
 * @Provenance C++: AngelscriptCoverageUEnumTests.cpp::UEnumInContainers
 * @Provenance Oracle after BeginPlay: ArraySize=3, MapSize=2, MapLookupResult=200, bSetContainsItem2=true.
 * @Provenance Extra: empty containers before BeginPlay; nullptr actor is the empty handle; duplicate Item2 does not grow the set.
 * @Provenance FixtureIsolated. Keep ArraySize/MapSize/MapLookupResult/bSetContainsItem2 names.
 */

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

	/**
	 * WorldStory: fill the array, set, and both maps, including a duplicate Item2
	 * that must not grow the set.
	 *
	 * @Kind WorldStory
	 * @Covers UEnum.UEnumInContainers
	 * @Inputs none
	 * @Return ArraySize 3, MapSize 2, MapLookupResult 200, bSetContainsItem2 true
	 */
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

	/**
	 * Observe that containers and size fields start empty before play.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumInContainers
	 * @Inputs a locally constructed actor
	 * @Return true when every container is empty and the size fields are 0
	 * @Boundary empty defaults
	 */
	UFUNCTION()
	bool EmptyDefaults()
	{
		if (EnumArray.Num() != 0)
		{
			return false;
		}
		if (EnumSet.Num() != 0)
		{
			return false;
		}
		if (EnumToIntMap.Num() != 0)
		{
			return false;
		}
		if (IntToEnumMap.Num() != 0)
		{
			return false;
		}
		if (ArraySize != 0)
		{
			return false;
		}
		if (MapSize != 0)
		{
			return false;
		}
		if (MapLookupResult != 0)
		{
			return false;
		}
		return !bSetContainsItem2;
	}

	/**
	 * Observe the BeginPlay oracle for array, map, and set contents.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumInContainers
	 * @Inputs this actor after BeginPlay
	 * @Return true when ArraySize is 3, MapSize is 2, lookup is 200, and Item2 is in the set
	 */
	UFUNCTION()
	bool BeginPlayOracle()
	{
		BeginPlay();
		if (ArraySize != 3)
		{
			return false;
		}
		if (MapSize != 2)
		{
			return false;
		}
		if (MapLookupResult != 200)
		{
			return false;
		}
		if (!bSetContainsItem2)
		{
			return false;
		}
		if (EnumArray.Num() != 3)
		{
			return false;
		}
		return EnumArray[1] == EContainerEnum::Item3;
	}

	/**
	 * Observe that a local null handle of this actor type is null.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumInContainers
	 * @Inputs a locally constructed null handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ACoverageUEnumContainersActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe that adding Item2 twice leaves a set of size 1.
	 *
	 * @Kind Observe
	 * @Covers UEnum.UEnumInContainers
	 * @Inputs a local set with Item2 added twice
	 * @Return true when the set has one element and contains Item2
	 * @Boundary duplicate set insert
	 */
	UFUNCTION()
	bool SetDuplicateBoundary()
	{
		TSet<EContainerEnum> Isolated;
		Isolated.Add(EContainerEnum::Item2);
		Isolated.Add(EContainerEnum::Item2);
		if (Isolated.Num() != 1)
		{
			return false;
		}
		return Isolated.Contains(EContainerEnum::Item2);
	}
}
