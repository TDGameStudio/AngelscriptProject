/**
 * TArray and TMap properties holding FTransforms, filled during BeginPlay. C++ verifies
 * the element counts and the individual translations by path, so the UPROPERTY names are
 * part of the contract and are kept verbatim. The observers cover the empty state before
 * BeginPlay and the independence of two instances.
 *
 * @Theme Gameplay.FTransform
 * @Subject FTransform.ContainerProperties
 * @Harness UClass
 * @Tag Gameplay.FTransform.FTransformContainerProperties
 * @Provenance Theme: Gameplay.FTransform. WorldStory TArray/TMap container properties.
 * @Provenance C++: AngelscriptCoverageFTransformPropertyTests.cpp::FTransformContainerProperties
 * @Provenance Oracle after BeginPlay: TransformArray Num 3; [0].Translation.X 100;
 * @Provenance [0].Y 0; [1].Y 200; [2].Z 300. IntToTransformMap Num 3; [1].X 10; [2].Y 20;
 * @Provenance [3].Z 30. Extra: empty containers before BeginPlay. FixtureIsolated.
 * @Provenance Keep UPROPERTY names.
 */

UCLASS()
class ACoverageFTransformContainerActor : AActor
{
	UPROPERTY()
	TArray<FTransform> TransformArray;

	UPROPERTY()
	TMap<int, FTransform> IntToTransformMap;

	/**
	 * WorldStory: BeginPlay fills the array and the map with three transforms each, one per
	 * axis.
	 *
	 * @Kind WorldStory
	 * @Covers FTransform.ContainerProperties
	 * @Inputs none
	 * @Return three entries in each container
	 */
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

	/**
	 * Observe that both containers start empty.
	 *
	 * @Kind Observe
	 * @Covers FTransform.ContainerProperties
	 * @Inputs none
	 * @Return true when both counts are 0
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (TransformArray.Num() != 0)
		{
			return false;
		}
		return IntToTransformMap.Num() == 0;
	}

	/**
	 * Observe that BeginPlay fills the array with one transform per axis.
	 *
	 * @Kind Observe
	 * @Covers FTransform.ContainerProperties
	 * @Inputs none
	 * @Return true when the array holds three entries translated along X, Y and Z in turn
	 */
	UFUNCTION()
	bool TransformArrayAfterBeginPlay()
	{
		BeginPlay();

		if (TransformArray.Num() != 3)
		{
			return false;
		}
		if (TransformArray[0].GetLocation().X != 100.0)
		{
			return false;
		}
		if (TransformArray[0].GetLocation().Y != 0.0)
		{
			return false;
		}
		if (TransformArray[1].GetLocation().Y != 200.0)
		{
			return false;
		}
		return TransformArray[2].GetLocation().Z == 300.0;
	}

	/**
	 * Observe that BeginPlay fills the map with one transform per axis.
	 *
	 * @Kind Observe
	 * @Covers FTransform.ContainerProperties
	 * @Inputs none
	 * @Return true when the map holds three entries keyed 1, 2 and 3
	 */
	UFUNCTION()
	bool IntToTransformMapAfterBeginPlay()
	{
		BeginPlay();

		if (IntToTransformMap.Num() != 3)
		{
			return false;
		}
		if (IntToTransformMap[1].GetLocation().X != 10.0)
		{
			return false;
		}
		if (IntToTransformMap[2].GetLocation().Y != 20.0)
		{
			return false;
		}
		return IntToTransformMap[3].GetLocation().Z == 30.0;
	}

	/**
	 * Observe that filling one instance leaves another instance empty.
	 *
	 * @Kind Observe
	 * @Covers FTransform.ContainerProperties
	 * @Inputs a second actor
	 * @Return true when this instance holds three entries and the other holds none
	 * @Param Second the other actor, expected to stay empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageFTransformContainerActor Second)
	{
		if (Second is null)
		{
			throw("FTransformContainerProperties setup: required Second is null");
		}
		BeginPlay();

		if (TransformArray.Num() != 3)
		{
			return false;
		}
		if (Second.TransformArray.Num() != 0)
		{
			return false;
		}
		return Second.IntToTransformMap.Num() == 0;
	}
}
