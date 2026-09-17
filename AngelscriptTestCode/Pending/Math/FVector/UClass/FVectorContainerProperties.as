/**
 * @version v1
 * @summary TArray and TMap properties holding FVectors, filled during BeginPlay. C++ verifies the element counts and the individual components by path, so the UPROPERTY names are part of the contract and are kept verbatim. The.
 * @topic Math
 */
/**
 * @version root
 * @summary TArray and TMap properties holding FVectors, filled during BeginPlay. C++ verifies the element counts and the individual components by path, so the UPROPERTY names are part of the contract and are kept verbatim. The.
 * @topic Baseline
 */
UCLASS()
class ACoverageFVectorContainerActor : AActor
{
	UPROPERTY()
	TArray<FVector> VectorArray;

	UPROPERTY()
	TMap<int, FVector> IntToVectorMap;

	/**
	 * WorldStory: BeginPlay fills the array with the three basis vectors and the map with
	 * the three named directions.
	 *
	 * @Kind WorldStory
	 * @Covers FVector.ContainerProperties
	 * @Inputs none
	 * @Return three entries in each container
	 */
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

	/**
	 * Observe that both containers start empty.
	 *
	 * @Kind Observe
	 * @Covers FVector.ContainerProperties
	 * @Inputs none
	 * @Return true when both counts are 0
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (VectorArray.Num() != 0)
		{
			return false;
		}
		return IntToVectorMap.Num() == 0;
	}

	/**
	 * Observe that BeginPlay fills the array with the three basis vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector.ContainerProperties
	 * @Inputs none
	 * @Return true when the array holds three entries with X, Y and Z set in turn
	 */
	UFUNCTION()
	bool VectorArrayAfterBeginPlay()
	{
		BeginPlay();

		if (VectorArray.Num() != 3)
		{
			return false;
		}
		if (VectorArray[0].X != 1.0)
		{
			return false;
		}
		if (VectorArray[0].Y != 0.0)
		{
			return false;
		}
		if (VectorArray[1].Y != 1.0)
		{
			return false;
		}
		return VectorArray[2].Z == 1.0;
	}

	/**
	 * Observe that BeginPlay fills the map with the three named directions.
	 *
	 * @Kind Observe
	 * @Covers FVector.ContainerProperties
	 * @Inputs none
	 * @Return true when the map holds three entries keyed 1, 2 and 3
	 */
	UFUNCTION()
	bool IntToVectorMapAfterBeginPlay()
	{
		BeginPlay();

		if (IntToVectorMap.Num() != 3)
		{
			return false;
		}
		if (IntToVectorMap[1].X != 1.0)
		{
			return false;
		}
		return IntToVectorMap[3].Z == 1.0;
	}

	/**
	 * Observe that filling one instance leaves another instance empty.
	 *
	 * @Kind Observe
	 * @Covers FVector.ContainerProperties
	 * @Inputs a second actor
	 * @Return true when this instance holds three entries and the other holds none
	 * @Param Second the other actor, expected to stay empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageFVectorContainerActor Second)
	{
		if (Second is null)
		{
			throw("FVectorContainerProperties setup: required Second is null");
		}
		BeginPlay();

		if (VectorArray.Num() != 3)
		{
			return false;
		}
		return Second.VectorArray.Num() == 0;
	}
}
/** @end */
