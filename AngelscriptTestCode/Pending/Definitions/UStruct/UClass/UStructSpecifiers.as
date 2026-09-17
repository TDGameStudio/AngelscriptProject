/**
 * @version v1
 * @summary A USTRUCT(BlueprintType) member on an actor. C++ reads BPData.Value after BeginPlay and checks BlueprintType metadata.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A USTRUCT(BlueprintType) member on an actor. C++ reads BPData.Value after BeginPlay and checks BlueprintType metadata.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FBlueprintTypeStruct
{
	UPROPERTY()
	int Value = 10;
}

UCLASS()
class ACoverageStructSpecifierActor : AActor
{
	UPROPERTY()
	FBlueprintTypeStruct BPData;

	/**
	 * WorldStory: BeginPlay writes the BlueprintType member C++ reads by path.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.UStructSpecifiers
	 * @Inputs none
	 * @Return BPData.Value 100
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BPData.Value = 100;
	}

	/**
	 * Observe the BlueprintType struct default.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructSpecifiers
	 * @Inputs a default-constructed FBlueprintTypeStruct
	 * @Return true when Value is 10
	 * @Boundary default value
	 */
	UFUNCTION()
	bool BlueprintTypeDefaultEmpty()
	{
		FBlueprintTypeStruct LocalData;
		return LocalData.Value == 10;
	}

	/**
	 * Observe the BeginPlay oracle value on a local struct.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructSpecifiers
	 * @Inputs a struct whose Value was set to 100
	 * @Return 100
	 */
	UFUNCTION()
	int BlueprintTypeBeginPlayOracle()
	{
		FBlueprintTypeStruct LocalData;
		LocalData.Value = 100;
		return LocalData.Value;
	}

	/**
	 * Observe that copying the BlueprintType struct does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.UStructSpecifiers
	 * @Inputs a copy whose Value was set to 0
	 * @Return true when the original stays 10 and the copy is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BlueprintTypeCopyIndependence()
	{
		FBlueprintTypeStruct Original;
		FBlueprintTypeStruct Copy = Original;
		Copy.Value = 0;
		if (Original.Value != 10)
		{
			return false;
		}
		return Copy.Value == 0;
	}
}
/** @end */
