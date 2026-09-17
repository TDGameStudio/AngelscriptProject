/**
 * @version v1
 * @summary TArray and TMap properties holding FLinearColors, filled during BeginPlay. C++ verifies the element counts and the individual components by path, so the UPROPERTY names are part of the contract and are kept verbatim. The.
 * @topic Math
 */
/**
 * @version root
 * @summary TArray and TMap properties holding FLinearColors, filled during BeginPlay. C++ verifies the element counts and the individual components by path, so the UPROPERTY names are part of the contract and are kept verbatim. The.
 * @topic Baseline
 */
UCLASS()
class ACoverageFLinearColorContainerActor : AActor
{
	UPROPERTY()
	TArray<FLinearColor> ColorArray;

	UPROPERTY()
	TMap<int, FLinearColor> IntToColorMap;

	/**
	 * WorldStory: BeginPlay fills the array with red, green and blue and the map with
	 * white, black and yellow.
	 *
	 * @Kind WorldStory
	 * @Covers FLinearColor.ContainerProperties
	 * @Inputs none
	 * @Return three entries in each container
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ColorArray.Add(FLinearColor::Red);
		ColorArray.Add(FLinearColor::Green);
		ColorArray.Add(FLinearColor::Blue);

		IntToColorMap.Add(1, FLinearColor::White);
		IntToColorMap.Add(2, FLinearColor::Black);
		IntToColorMap.Add(3, FLinearColor::Yellow);
	}

	/**
	 * Observe that both containers start empty.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ContainerProperties
	 * @Inputs none
	 * @Return true when both counts are 0
	 * @Boundary empty containers
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ColorArray.Num() != 0)
		{
			return false;
		}
		return IntToColorMap.Num() == 0;
	}

	/**
	 * Observe that BeginPlay fills the array with red, green and blue.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ContainerProperties
	 * @Inputs none
	 * @Return true when the array holds three entries with R, G and B set in turn
	 */
	UFUNCTION()
	bool ColorArrayAfterBeginPlay()
	{
		BeginPlay();

		if (ColorArray.Num() != 3)
		{
			return false;
		}
		if (ColorArray[0].R != 1.0)
		{
			return false;
		}
		if (ColorArray[0].G != 0.0)
		{
			return false;
		}
		if (ColorArray[1].G != 1.0)
		{
			return false;
		}
		return ColorArray[2].B == 1.0;
	}

	/**
	 * Observe that BeginPlay fills the map with white, black and yellow.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ContainerProperties
	 * @Inputs none
	 * @Return true when the map holds three entries keyed 1, 2 and 3
	 */
	UFUNCTION()
	bool IntToColorMapAfterBeginPlay()
	{
		BeginPlay();

		if (IntToColorMap.Num() != 3)
		{
			return false;
		}
		if (IntToColorMap[1].R != 1.0)
		{
			return false;
		}
		if (IntToColorMap[1].G != 1.0)
		{
			return false;
		}
		return IntToColorMap[2].R == 0.0;
	}

	/**
	 * Observe that filling one instance leaves another instance empty.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.ContainerProperties
	 * @Inputs a second actor
	 * @Return true when this instance holds three entries and the other holds none
	 * @Param Second the other actor, expected to stay empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageFLinearColorContainerActor Second)
	{
		if (Second is null)
		{
			throw("FLinearColorContainerProperties setup: required Second is null");
		}
		BeginPlay();

		if (ColorArray.Num() != 3)
		{
			return false;
		}
		return Second.ColorArray.Num() == 0;
	}
}
/** @end */
