// Theme: Definitions.UFunction. WorldStory specifier metadata plus const getter and Exec.
// C++: AngelscriptCoverageMacrosTests.cpp::UFunctionSpecifiersMetadataAndConstReflection
// Oracle: SetStoredValue writes StoredValue; GetStoredValue/ReadValue return it; CoverageConsoleCommand writes 77.
// Extra: StoredValue default 5; nullptr actor is the empty handle; VisibleAction with null Target and empty label.
// FixtureIsolated. Keep StoredValue name.

UCLASS()
class ACoverageMacrosFunctionSpecifiersActor : AActor
{
	UPROPERTY()
	int StoredValue = 5;

	UFUNCTION()
	void SetStoredValue(int Value)
	{
		StoredValue = Value;
	}

	UFUNCTION()
	int GetStoredValue() const
	{
		return StoredValue;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Functions", CallInEditor, meta=(
		DisplayName="Visible Coverage Action",
		Keywords="coverage macro function",
		ToolTip="Full function tooltip",
		ShortToolTip="Short function tooltip",
		CompactNodeTitle="ACT",
		AdvancedDisplay="OptionalValue,OptionalLabel",
		WorldContext="Target",
		DefaultToSelf="Target",
		HidePin="Target",
		AutoCreateRefTerm="OptionalLabel"))
	void VisibleAction(UObject Target, int RequiredValue, int OptionalValue, const FString&in OptionalLabel)
	{
		StoredValue = RequiredValue + OptionalValue + OptionalLabel.Len();
		if (Target != nullptr)
		{
			StoredValue += 1;
		}
	}

	UFUNCTION(BlueprintPure, Category="Coverage|Functions", meta=(DisplayName="Read Coverage Value"))
	int ReadValue() const
	{
		return StoredValue;
	}

	UFUNCTION(Exec, Category="Coverage|Console")
	void CoverageConsoleCommand()
	{
		StoredValue = 77;
	}
}

bool Observe_Specifiers_DefaultFive(ACoverageMacrosFunctionSpecifiersActor Actor)
{
	return Actor.GetStoredValue() == 5 && Actor.ReadValue() == 5;
}

bool Observe_Specifiers_NullTargetEmptyLabel(ACoverageMacrosFunctionSpecifiersActor Actor)
{
	Actor.VisibleAction(nullptr, 0, 0, "");
	return Actor.StoredValue == 0 && Actor.ReadValue() == 0;
}

bool Observe_Specifiers_NullDefault()
{
	ACoverageMacrosFunctionSpecifiersActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_Specifiers_ExecBoundary(ACoverageMacrosFunctionSpecifiersActor Actor)
{
	Actor.SetStoredValue(11);
	bool bSet = Actor.GetStoredValue() == 11;
	Actor.CoverageConsoleCommand();
	return bSet && Actor.StoredValue == 77 && Actor.ReadValue() == 77;
}
