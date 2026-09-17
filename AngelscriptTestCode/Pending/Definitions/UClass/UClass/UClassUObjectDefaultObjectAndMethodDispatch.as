/**
 * @version v1
 * @summary UObject CDO defaults plus UFUNCTION dispatch. CDO Counter is 12 and Label is Seed; AddCounter(8) returns 20; BuildLabel("Done") is "Seed_Done". Keep Counter, Label, AddCounter, and BuildLabel.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UObject CDO defaults plus UFUNCTION dispatch. CDO Counter is 12 and Label is Seed; AddCounter(8) returns 20; BuildLabel("Done") is "Seed_Done". Keep Counter, Label, AddCounter, and BuildLabel.
 * @topic Baseline
 */
UCLASS(BlueprintType)
class UCoverageUClassPlainDataObject : UObject
{
	UPROPERTY()
	int Counter = 12;

	UPROPERTY()
	FString Label = "Seed";

	/**
	 * Observe AddCounter: it adds Value into Counter and returns the new total.
	 *
	 * @Kind Observe
	 * @Covers UClass.UObject
	 * @Param Value Amount added
	 * @Inputs Counter += Value
	 * @Return Counter
	 */
	UFUNCTION()
	int AddCounter(int Value)
	{
		Counter += Value;
		return Counter;
	}

	/**
	 * Observe BuildLabel: it concatenates Label, underscore, and Suffix.
	 *
	 * @Kind Observe
	 * @Covers UClass.UObject
	 * @Param Suffix Trailing fragment
	 * @Inputs Label + "_" + Suffix
	 * @Return the concatenated label
	 */
	UFUNCTION()
	FString BuildLabel(const FString&in Suffix)
	{
		return Label + "_" + Suffix;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.UObject
	 * @Inputs an unset UCoverageUClassPlainDataObject handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageUClassPlainDataObject Obj;
		return Obj == nullptr;
	}

	/**
	 * Observe AddCounter(8) from Counter 12.
	 *
	 * @Kind Observe
	 * @Covers UClass.UObject
	 * @Inputs Counter=12, AddCounter(8)
	 * @Return 20
	 */
	UFUNCTION()
	int AddCounterNominal()
	{
		Counter = 12;
		return AddCounter(8);
	}

	/**
	 * Observe AddCounter(0) leaving Counter at 12.
	 *
	 * @Kind Observe
	 * @Covers UClass.UObject
	 * @Inputs Counter=12, AddCounter(0)
	 * @Return 12
	 * @Boundary zero addend
	 */
	UFUNCTION()
	int AddCounterZeroBoundary()
	{
		Counter = 12;
		return AddCounter(0);
	}

	/**
	 * Observe BuildLabel("Done") from Label Seed.
	 *
	 * @Kind Observe
	 * @Covers UClass.UObject
	 * @Inputs Label="Seed", BuildLabel("Done")
	 * @Return "Seed_Done"
	 */
	UFUNCTION()
	FString BuildLabelNominal()
	{
		Label = "Seed";
		return BuildLabel("Done");
	}

	/**
	 * Observe BuildLabel("") from Label Seed.
	 *
	 * @Kind Observe
	 * @Covers UClass.UObject
	 * @Inputs Label="Seed", BuildLabel("")
	 * @Return "Seed_"
	 * @Boundary empty suffix
	 */
	UFUNCTION()
	FString BuildLabelEmptySuffix()
	{
		Label = "Seed";
		return BuildLabel("");
	}
}
/** @end */
