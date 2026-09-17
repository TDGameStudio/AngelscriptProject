/**
 * @version v1
 * @summary TArray and TMap properties holding FVector2Ds, filled during BeginPlay. C++ verifies the element counts and the individual components by path, so the UPROPERTY names are part of the contract and are kept verbatim. The.
 * @topic Math
 */
/**
 * @version root
 * @summary TArray and TMap properties holding FVector2Ds, filled during BeginPlay. C++ verifies the element counts and the individual components by path, so the UPROPERTY names are part of the contract and are kept verbatim. The.
 * @topic Baseline
 */
UCLASS()
class ACoverageFVector2DContainerActor : AActor
{
	UPROPERTY()
	TArray<FVector2D> VectorArray;

	UPROPERTY()
	TMap<int, FVector2D> IntToVectorMap;

	/**
	 * WorldStory: BeginPlay fills the array with three axis vectors and the map with two
	 * populated entries and a zero vector.
	 *
	 * @Kind WorldStory
	 * @Covers FVector2D.ContainerProperties
	 * @Inputs none
	 * @Return three entries in each container
	 */
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

	/**
	 * Observe that both containers start empty.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ContainerProperties
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
	 * Observe that BeginPlay fills the array with the three axis vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ContainerProperties
	 * @Inputs none
	 * @Return true when the array holds three entries with (1,0), Y=1 and (1,1)
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
		if (VectorArray[2].X != 1.0)
		{
			return false;
		}
		return VectorArray[2].Y == 1.0;
	}

	/**
	 * Observe that BeginPlay fills the map with the three keyed vectors.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ContainerProperties
	 * @Inputs none
	 * @Return true when the map holds three entries keyed 1 and 3 as expected
	 */
	UFUNCTION()
	bool IntToVectorMapAfterBeginPlay()
	{
		BeginPlay();

		if (IntToVectorMap.Num() != 3)
		{
			return false;
		}
		if (IntToVectorMap[1].X != 10.0)
		{
			return false;
		}
		if (IntToVectorMap[1].Y != 20.0)
		{
			return false;
		}
		return IntToVectorMap[3].X == 0.0;
	}

	/**
	 * Observe that filling one instance leaves another instance empty.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.ContainerProperties
	 * @Inputs a second actor
	 * @Return true when this instance holds three entries and the other holds none
	 * @Param Second the other actor, expected to stay empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageFVector2DContainerActor Second)
	{
		if (Second is null)
		{
			throw("FVector2DContainerProperties setup: required Second is null");
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
