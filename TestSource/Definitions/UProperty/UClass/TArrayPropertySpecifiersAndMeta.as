/**
 * BlueprintReadWrite TArray plus ClampMin/ClampMax metadata array. C++ verifies
 * named properties by path, so those UPROPERTY names are kept. The observers
 * cover empty array Num 0 before Add.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.TArrayPropertySpecifiersAndMeta
 * @Harness UClass
 * @Tag Definitions.UProperty.TArrayPropertySpecifiersAndMeta
 * @Provenance Theme: Definitions.UProperty. WorldStory: BlueprintReadWrite TArray plus ClampMin/ClampMax metadata array.
 * @Provenance C++: BlueprintValues CPF_BlueprintVisible not ReadOnly; ClampedValues ClampMin 0 ClampMax 10.
 * @Provenance Extra: empty arrays Num 0 before Add. FixtureIsolated.
 */

UCLASS()
class ACoverageTArrayPropertySpecifierActor : AActor
{
	UPROPERTY(BlueprintReadWrite)
	TArray<int> BlueprintValues;

	UPROPERTY(meta = (ClampMin = "0", ClampMax = "10"))
	TArray<int> ClampedValues;

	/**
	 * WorldStory: fill both arrays after play begins.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.TArrayPropertySpecifiersAndMeta
	 * @Inputs none
	 * @Return BlueprintValues holds 1,2 and ClampedValues holds 3
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BlueprintValues.Add(1);
		BlueprintValues.Add(2);
		ClampedValues.Add(3);
	}

	/**
	 * Observe that an empty BlueprintValues array has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TArrayPropertySpecifiersAndMeta
	 * @Inputs a default-constructed TArray<int>
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int TArraySpecifierEmptyBlueprintNum()
	{
		TArray<int> BlueprintValues;
		return BlueprintValues.Num();
	}

	/**
	 * Observe that an empty ClampedValues array has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TArrayPropertySpecifiersAndMeta
	 * @Inputs a default-constructed TArray<int>
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int TArraySpecifierEmptyClampedNum()
	{
		TArray<int> ClampedValues;
		return ClampedValues.Num();
	}
}
