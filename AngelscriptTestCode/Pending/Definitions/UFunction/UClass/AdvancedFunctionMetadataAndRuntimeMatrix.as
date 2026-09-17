/**
 * @version v1
 * @summary Rich UFUNCTION metadata plus an EditorOnly companion. C++ verifies MetadataRichAction(this, class, "Meta", 30, 5) == 42, so those names are part of the contract and are kept verbatim.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Rich UFUNCTION metadata plus an EditorOnly companion. C++ verifies MetadataRichAction(this, class, "Meta", 30, 5) == 42, so those names are part of the contract and are kept verbatim.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionAdvancedMetadataActor : AActor
{
	UPROPERTY()
	int LastScore = 0;

	/**
	 * Score a rich-metadata action from target, class, label length, required and optional values.
	 *
	 * @Kind Observe
	 * @Covers UFunction.AdvancedFunctionMetadataAndRuntimeMatrix
	 * @Inputs a target, a class, a label, a required value and an optional value
	 * @Return LastScore written from the presence bits, label length and values
	 * @Param Target the optional target object
	 * @Param RequestedClass the optional class
	 * @Param Label the label whose length is scored
	 * @Param RequiredValue the required integer
	 * @Param OptionalValue the optional integer, default 5
	 */
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

	/**
	 * Editor-only companion action with no runtime state.
	 *
	 * @Kind Action
	 * @Covers UFunction.AdvancedFunctionMetadataAndRuntimeMatrix
	 * @Inputs none
	 * @Return no runtime state
	 */
	UFUNCTION(BlueprintCallable, meta=(EditorOnly))
	void EditorOnlyMetaAction()
	{
	}

	/**
	 * Observe that the nominal metadata-rich call scores 42.
	 *
	 * @Kind Observe
	 * @Covers UFunction.AdvancedFunctionMetadataAndRuntimeMatrix
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int Nominal42()
	{
		return MetadataRichAction(
			this,
			ACoverageUFunctionAdvancedMetadataActor::StaticClass(),
			"Meta",
			30,
			5);
	}

	/**
	 * Observe that nulls, an empty label and the default optional value score 5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.AdvancedFunctionMetadataAndRuntimeMatrix
	 * @Inputs none
	 * @Return 5
	 * @Boundary empty/null
	 */
	UFUNCTION()
	int NullEmptyDefaultOptional()
	{
		return MetadataRichAction(nullptr, nullptr, "", 0);
	}

	/**
	 * Observe that an untouched actor has LastScore 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.AdvancedFunctionMetadataAndRuntimeMatrix
	 * @Inputs none
	 * @Return LastScore
	 * @Boundary default value
	 */
	UFUNCTION()
	int DefaultScore()
	{
		return LastScore;
	}
}
/** @end */
