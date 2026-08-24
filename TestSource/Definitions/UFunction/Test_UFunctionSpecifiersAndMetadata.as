// Theme: Definitions.UFunction. WorldStory BlueprintCallable/Pure/Exec plus DisplayName metadata.
// C++: AngelscriptCoverageUFunctionTests.cpp::UFunctionSpecifiersAndMetadata
// Oracle: VisibleAction writes StoredValue; ReadStoredValue returns it; CoverageExecCommand writes 77.
// Extra: StoredValue default 0; nullptr actor is the empty handle; VisibleAction(0) empty write.
// FixtureIsolated. Keep StoredValue name.

UCLASS()
class ACoverageUFunctionSpecifiersActor : AActor
{
	UPROPERTY()
	int StoredValue = 0;

	UFUNCTION(BlueprintCallable, Category="Coverage|Functions", CallInEditor, meta=(DisplayName="Visible Action", Keywords="coverage keyword action", ToolTip="Function tooltip text", ShortToolTip="Short function tooltip", CompactNodeTitle="ACT"))
	void VisibleAction(int Value)
	{
		StoredValue = Value;
	}

	UFUNCTION(BlueprintPure, Category="Coverage|Functions", meta=(DisplayName="Read Stored Value"))
	int ReadStoredValue() const
	{
		return StoredValue;
	}

	UFUNCTION(Exec, Category="Coverage|Console")
	void CoverageExecCommand()
	{
		StoredValue = 77;
	}
}

bool Observe_SpecifiersMeta_EmptyDefault(ACoverageUFunctionSpecifiersActor Actor)
{
	return Actor.ReadStoredValue() == 0 && Actor.StoredValue == 0;
}

bool Observe_SpecifiersMeta_ZeroWrite(ACoverageUFunctionSpecifiersActor Actor)
{
	Actor.VisibleAction(0);
	return Actor.ReadStoredValue() == 0;
}

bool Observe_SpecifiersMeta_NullDefault()
{
	ACoverageUFunctionSpecifiersActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_SpecifiersMeta_ExecBoundary(ACoverageUFunctionSpecifiersActor Actor)
{
	Actor.VisibleAction(11);
	bool bVisible = Actor.ReadStoredValue() == 11;
	Actor.CoverageExecCommand();
	return bVisible && Actor.ReadStoredValue() == 77 && Actor.StoredValue == 77;
}
