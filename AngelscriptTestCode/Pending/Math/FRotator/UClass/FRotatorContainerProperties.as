/**
 * @version v1
 * @summary TArray and TMap properties holding FRotators, filled during BeginPlay. C++ verifies the element counts and the individual components by path, so the UPROPERTY names are part of the contract and are kept verbatim.
 * @topic Math
 */
/**
 * @version root
 * @summary TArray and TMap properties holding FRotators, filled during BeginPlay. C++ verifies the element counts and the individual components by path, so the UPROPERTY names are part of the contract and are kept verbatim.
 * @topic Baseline
 */
UCLASS()
class ACoverageFRotatorContainerActor : AActor
{
	UPROPERTY()
	TArray<FRotator> RotatorArray;

	UPROPERTY()
	TMap<int, FRotator> IntToRotatorMap;

	/**
	 * WorldStory: BeginPlay fills the array and the map with three rotators each.
	 *
	 * @Kind WorldStory
	 * @Covers FRotator.ContainerProperties
	 * @Inputs none
	 * @Return RotatorArray and IntToRotatorMap each hold three rotators
	 */
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

	/**
	 * Observe that untouched containers are empty.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ContainerProperties
	 * @Inputs none
	 * @Return true when both containers have Num 0
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RotatorArray.Num() != 0)
		{
			return false;
		}
		return IntToRotatorMap.Num() == 0;
	}

	/**
	 * Observe that the array after BeginPlay holds the three constructed rotators.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ContainerProperties
	 * @Inputs none
	 * @Return true when Num is 3 and the sampled components match
	 */
	UFUNCTION()
	bool RotatorArrayAfterBeginPlay()
	{
		BeginPlay();

		if (RotatorArray.Num() != 3)
		{
			return false;
		}
		if (RotatorArray[0].Pitch != 0.0)
		{
			return false;
		}
		if (RotatorArray[1].Pitch != 90.0)
		{
			return false;
		}
		return RotatorArray[2].Yaw == 180.0;
	}

	/**
	 * Observe that the map after BeginPlay holds the three constructed rotators.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ContainerProperties
	 * @Inputs none
	 * @Return true when Num is 3 and the sampled components match
	 */
	UFUNCTION()
	bool IntToRotatorMapAfterBeginPlay()
	{
		BeginPlay();

		if (IntToRotatorMap.Num() != 3)
		{
			return false;
		}
		if (IntToRotatorMap[1].Pitch != 45.0)
		{
			return false;
		}
		if (IntToRotatorMap[2].Yaw != 90.0)
		{
			return false;
		}
		return IntToRotatorMap[3].Roll == 45.0;
	}

	/**
	 * Observe that mutating a copied element leaves the array untouched.
	 *
	 * @Kind Observe
	 * @Covers FRotator.ContainerProperties
	 * @Inputs a copy of RotatorArray[1]
	 * @Return true when the array element is still (90, 0, 0)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool RotatorArrayCopyIndependence()
	{
		BeginPlay();
		FRotator Copy = RotatorArray[1];
		Copy.Pitch = 0.0;
		return RotatorArray[1] == FRotator(90, 0, 0);
	}
}
/** @end */
