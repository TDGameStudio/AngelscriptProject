/**
 * BlueprintPure out-only and inout with no return property. FillPureOut(5)
 * writes 22 / "Base:5". MutatePureInout(4,"Seed") writes 21 / "Seed:Base".
 * DispatchPureOutMatrix is 59 and StoredLabel "Base:5|Input:Base".
 * FillPureOut(0) writes StoredValue 17. Defaults are StoredValue 17 and
 * StoredLabel "Base".
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.BlueprintPureOutOnlyAndInoutRuntimeMatrix
 * @Harness UClass
 * @Tag Definitions.UFunction.BlueprintPureOutOnlyAndInoutRuntimeMatrix
 * @Provenance Theme: Definitions.UFunction. WorldStory: BlueprintPure out-only and inout, no return property.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintPureOutOnlyAndInoutRuntimeMatrix
 * @Provenance FillPureOut(5) writes 22 / "Base:5"; MutatePureInout(4,"Seed") writes 21 / "Seed:Base";
 * @Provenance DispatchPureOutMatrix == 59 and StoredLabel "Base:5|Input:Base".
 * @Provenance Extra: FillPureOut(0) writes StoredValue 17; default StoredValue 17 StoredLabel "Base".
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageUFunctionPureOutActor : AActor
{
	UPROPERTY()
	int StoredValue = 17;

	UPROPERTY()
	FString StoredLabel = "Base";

	/**
	 * Fill out value and label from StoredValue + Seed.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Seed Added to StoredValue
	 * @Param OutValue Destination received as int&out
	 * @Param OutLabel Destination received as FString&out
	 * @Inputs Seed plus two out slots
	 * @Return void
	 */
	UFUNCTION(BlueprintPure, Category="Coverage|PureOut", meta=(DisplayName="Fill Pure Out"))
	void FillPureOut(int Seed, int&out OutValue, FString&out OutLabel) const
	{
		OutValue = StoredValue + Seed;
		OutLabel = StoredLabel + ":" + Seed;
	}

	/**
	 * Mutate inout value and label using StoredValue and StoredLabel.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Value Integer received as int&inout
	 * @Param Label String received as FString&inout
	 * @Inputs Value and Label
	 * @Return void
	 */
	UFUNCTION(BlueprintPure, Category="Coverage|PureOut")
	void MutatePureInout(int&inout Value, FString&inout Label) const
	{
		Value += StoredValue;
		Label = Label + ":" + StoredLabel;
	}

	/**
	 * Dispatch FillPureOut(5) and MutatePureInout(3,"Input") and score the results.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs FillPureOut(5) then MutatePureInout(3, "Input")
	 * @Return OutValue + InOutValue + StoredLabel.Len()
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|PureOut")
	int DispatchPureOutMatrix()
	{
		int OutValue = 0;
		FString OutLabel;
		FillPureOut(5, OutValue, OutLabel);

		int InOutValue = 3;
		FString InOutLabel = "Input";
		MutatePureInout(InOutValue, InOutLabel);
		StoredLabel = OutLabel + "|" + InOutLabel;
		return OutValue + InOutValue + StoredLabel.Len();
	}

	/**
	 * Observe FillPureOut(5).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs FillPureOut(5)
	 * @Return true when OutValue is 22 and OutLabel is Base:5
	 */
	UFUNCTION()
	bool FillSeedFive()
	{
		int OutValue = 0;
		FString OutLabel;
		FillPureOut(5, OutValue, OutLabel);
		if (OutValue != 22)
		{
			return false;
		}
		return OutLabel == "Base:5";
	}

	/**
	 * Observe MutatePureInout of 4 / "Seed".
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs MutatePureInout(4, "Seed")
	 * @Return true when Value is 21 and Label is Seed:Base
	 */
	UFUNCTION()
	bool MutateSeed()
	{
		int Value = 4;
		FString Label = "Seed";
		MutatePureInout(Value, Label);
		if (Value != 21)
		{
			return false;
		}
		return Label == "Seed:Base";
	}

	/**
	 * Observe DispatchPureOutMatrix.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs DispatchPureOutMatrix()
	 * @Return 59
	 */
	UFUNCTION()
	int DispatchScore()
	{
		return DispatchPureOutMatrix();
	}

	/**
	 * Observe StoredLabel after DispatchPureOutMatrix.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs DispatchPureOutMatrix()
	 * @Return "Base:5|Input:Base"
	 */
	UFUNCTION()
	FString DispatchStoredLabel()
	{
		DispatchPureOutMatrix();
		return StoredLabel;
	}

	/**
	 * Observe FillPureOut(0) writing StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs FillPureOut(0)
	 * @Return 17
	 * @Boundary zero seed
	 */
	UFUNCTION()
	int FillZeroBoundary()
	{
		int OutValue = -1;
		FString OutLabel;
		FillPureOut(0, OutValue, OutLabel);
		return OutValue;
	}

	/**
	 * Observe the default StoredValue 17 and StoredLabel Base.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return true when StoredValue is 17 and StoredLabel is Base
	 * @Boundary defaults
	 */
	UFUNCTION()
	bool DefaultStored()
	{
		if (StoredValue != 17)
		{
			return false;
		}
		return StoredLabel == "Base";
	}
}
