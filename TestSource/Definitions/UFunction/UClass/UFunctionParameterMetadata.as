/**
 * AdvancedDisplay, DefaultToSelf, HidePin, and AutoCreateRefTerm metadata on
 * a UFUNCTION. ConfigureAdvanced generates with those keys; the body is a
 * no-op. An empty call uses a null Target and empty label, and a nullptr
 * actor is the empty handle.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UFunctionParameterMetadata
 * @Harness UClass
 * @Tag Definitions.UFunction.UFunctionParameterMetadata
 * @Provenance Theme: Definitions.UFunction. WorldStory AdvancedDisplay/DefaultToSelf/HidePin/AutoCreateRefTerm.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UFunctionParameterMetadata
 * @Provenance Oracle: ConfigureAdvanced generates with those metadata keys; body is a no-op.
 * @Provenance Extra: empty call with null Target and empty label; nullptr actor is the empty handle.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ACoverageUFunctionParameterActor : AActor
{
	/**
	 * No-op UFUNCTION carrying AdvancedDisplay, DefaultToSelf, HidePin, and AutoCreateRefTerm.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Target DefaultToSelf / HidePin object
	 * @Param RequiredValue Required integer
	 * @Param OptionalValue AdvancedDisplay integer
	 * @Param OptionalLabel AdvancedDisplay string received as const FString&in
	 * @Inputs Target, RequiredValue, OptionalValue, OptionalLabel
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Parameters", meta=(
		AdvancedDisplay="OptionalValue,OptionalLabel",
		DefaultToSelf="Target",
		HidePin="Target",
		AutoCreateRefTerm="OptionalLabel"))
	void ConfigureAdvanced(UObject Target, int RequiredValue, int OptionalValue, const FString&in OptionalLabel)
	{
	}

	/**
	 * Observe an empty ConfigureAdvanced call.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ConfigureAdvanced(nullptr, 0, 0, "")
	 * @Return 0
	 * @Boundary empty arguments
	 */
	UFUNCTION()
	int ConfigureAdvancedEmptyCall()
	{
		ConfigureAdvanced(nullptr, 0, 0, "");
		return 0;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ACoverageUFunctionParameterActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageUFunctionParameterActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe two ConfigureAdvanced calls in sequence.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs two ConfigureAdvanced calls
	 * @Return 1
	 */
	UFUNCTION()
	int ConfigureAdvancedRepeatCall()
	{
		ConfigureAdvanced(nullptr, 1, 2, "x");
		ConfigureAdvanced(this, 3, 4, "yz");
		return 1;
	}
}
