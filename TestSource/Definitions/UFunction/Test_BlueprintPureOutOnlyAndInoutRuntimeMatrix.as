// Theme: Definitions.UFunction. WorldStory: BlueprintPure out-only and inout, no return property.
// C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintPureOutOnlyAndInoutRuntimeMatrix
// FillPureOut(5) writes 22 / "Base:5"; MutatePureInout(4,"Seed") writes 21 / "Seed:Base";
// DispatchPureOutMatrix == 59 and StoredLabel "Base:5|Input:Base".
// Extra: FillPureOut(0) writes StoredValue 17; default StoredValue 17 StoredLabel "Base".
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionPureOutActor : AActor
{
	UPROPERTY()
	int StoredValue = 17;

	UPROPERTY()
	FString StoredLabel = "Base";

	UFUNCTION(BlueprintPure, Category="Coverage|PureOut", meta=(DisplayName="Fill Pure Out"))
	void FillPureOut(int Seed, int&out OutValue, FString&out OutLabel) const
	{
		OutValue = StoredValue + Seed;
		OutLabel = StoredLabel + ":" + Seed;
	}

	UFUNCTION(BlueprintPure, Category="Coverage|PureOut")
	void MutatePureInout(int&inout Value, FString&inout Label) const
	{
		Value += StoredValue;
		Label = Label + ":" + StoredLabel;
	}

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
}

bool Observe_PureOut_FillSeed5(ACoverageUFunctionPureOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintPureOutOnlyAndInoutRuntimeMatrix setup: required Actor is null");
	}
	int OutValue = 0;
	FString OutLabel;
	Actor.FillPureOut(5, OutValue, OutLabel);
	return OutValue == 22 && OutLabel == "Base:5";
}

bool Observe_PureOut_MutateSeed(ACoverageUFunctionPureOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintPureOutOnlyAndInoutRuntimeMatrix setup: required Actor is null");
	}
	int Value = 4;
	FString Label = "Seed";
	Actor.MutatePureInout(Value, Label);
	return Value == 21 && Label == "Seed:Base";
}

int Observe_PureOut_Dispatch(ACoverageUFunctionPureOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintPureOutOnlyAndInoutRuntimeMatrix setup: required Actor is null");
	}
	return Actor.DispatchPureOutMatrix();
}

FString Observe_PureOut_DispatchStoredLabel(ACoverageUFunctionPureOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintPureOutOnlyAndInoutRuntimeMatrix setup: required Actor is null");
	}
	Actor.DispatchPureOutMatrix();
	return Actor.StoredLabel;
}

int Observe_PureOut_FillZeroBoundary(ACoverageUFunctionPureOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintPureOutOnlyAndInoutRuntimeMatrix setup: required Actor is null");
	}
	int OutValue = -1;
	FString OutLabel;
	Actor.FillPureOut(0, OutValue, OutLabel);
	return OutValue;
}

bool Observe_PureOut_DefaultStored(ACoverageUFunctionPureOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BlueprintPureOutOnlyAndInoutRuntimeMatrix setup: required Actor is null");
	}
	return Actor.StoredValue == 17 && Actor.StoredLabel == "Base";
}
