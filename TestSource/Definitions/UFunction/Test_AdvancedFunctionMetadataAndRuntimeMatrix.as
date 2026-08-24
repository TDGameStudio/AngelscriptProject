// Theme: Definitions.UFunction. WorldStory: rich UFUNCTION metadata plus EditorOnly companion.
// C++: AngelscriptCoverageUFunctionTests.cpp::AdvancedFunctionMetadataAndRuntimeMatrix
// Oracle: MetadataRichAction(this, class, "Meta", 30, 5) == 42 LastScore 42.
// Extra: all-null empty label with default OptionalValue 5 scores 5; default LastScore 0.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionAdvancedMetadataActor : AActor
{
	UPROPERTY()
	int LastScore = 0;

	UFUNCTION(BlueprintCallable, BlueprintProtected, Category="Coverage|AdvancedMeta", meta=(ScriptName="CoverageRenamedAction", DeprecatedFunction, DeprecationMessage="Use ReplacementAction", DevelopmentOnly, BlueprintInternalUseOnly, DefaultToSelf="Target", HidePin="Target", AutoCreateRefTerm="Label", DeterminesOutputType="RequestedClass", ExpandEnumAsExecs="ExecResult", CustomCoverageKey="CustomValue"))
	int MetadataRichAction(UObject Target, UClass RequestedClass, FString Label, int RequiredValue, int OptionalValue = 5)
	{
		LastScore = (Target != nullptr ? 1 : 0)
			+ (RequestedClass != nullptr ? 2 : 0)
			+ Label.Len()
			+ RequiredValue
			+ OptionalValue;
		return LastScore;
	}

	UFUNCTION(BlueprintCallable, meta=(EditorOnly))
	void EditorOnlyMetaAction()
	{
	}
}

int Observe_AdvancedMeta_Nominal42(ACoverageUFunctionAdvancedMetadataActor Actor)
{
	if (Actor is null)
	{
		throw("Test_AdvancedFunctionMetadataAndRuntimeMatrix setup: required Actor is null");
	}
	return Actor.MetadataRichAction(
		Actor,
		ACoverageUFunctionAdvancedMetadataActor::StaticClass(),
		"Meta",
		30,
		5);
}

int Observe_AdvancedMeta_NullEmptyDefaultOptional(ACoverageUFunctionAdvancedMetadataActor Actor)
{
	if (Actor is null)
	{
		throw("Test_AdvancedFunctionMetadataAndRuntimeMatrix setup: required Actor is null");
	}
	return Actor.MetadataRichAction(nullptr, nullptr, "", 0);
}

int Observe_AdvancedMeta_DefaultScore(ACoverageUFunctionAdvancedMetadataActor Actor)
{
	if (Actor is null)
	{
		throw("Test_AdvancedFunctionMetadataAndRuntimeMatrix setup: required Actor is null");
	}
	return Actor.LastScore;
}
