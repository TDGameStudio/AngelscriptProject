/**
 * DisplayName, Keywords, ToolTip, AdvancedDisplay, and AutoCreateRefTerm.
 * ApplyMetaValue(Input, Scale, Offset, Label) is Input*Scale + Offset +
 * Label.Len(). An empty label has Len 0, a nullptr actor is the empty
 * handle, and Scale 0 is a zero-product boundary.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UFunctionDisplayAndParameterMeta
 * @Harness UClass
 * @Tag Definitions.UFunction.UFunctionDisplayAndParameterMeta
 * @Provenance Theme: Definitions.UFunction. WorldStory DisplayName/Keywords/ToolTip/AdvancedDisplay/AutoCreateRefTerm.
 * @Provenance C++: AngelscriptCoverageMetaSpecifierTests.cpp::UFunctionDisplayAndParameterMeta
 * @Provenance Oracle: ApplyMetaValue(Input, Scale, Offset, Label) == Input*Scale + Offset + Label.Len(); metadata is C++ side.
 * @Provenance Extra: empty label Len=0; nullptr actor is the empty handle; Scale=0 is a zero-product boundary.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ACoverageMetaUFunctionMetaActor : AActor
{
	/**
	 * Apply Input*Scale + Offset + Label.Len() with display metadata.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Input Left product operand
	 * @Param Scale Right product operand
	 * @Param Offset Added after the product
	 * @Param Label String whose length is added, received as const FString&in
	 * @Inputs Input, Scale, Offset, Label
	 * @Return Input * Scale + Offset + Label.Len()
	 */
	UFUNCTION(BlueprintCallable, Category = "Coverage|Meta", meta = (
		DisplayName = "Apply Meta Value",
		Keywords = "coverage meta function",
		ToolTip = "Applies metadata",
		ShortToolTip = "Apply meta",
		CompactNodeTitle = "META",
		AdvancedDisplay = "Scale,Offset",
		AutoCreateRefTerm = "Label"))
	int ApplyMetaValue(
		int Input,
		int Scale,
		int Offset,
		const FString&in Label)
	{
		return Input * Scale + Offset + Label.Len();
	}

	/**
	 * Observe ApplyMetaValue(4, 5, 6, "ab").
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ApplyMetaValue(4, 5, 6, "ab")
	 * @Return true when the result is 28
	 */
	UFUNCTION()
	bool DisplayMetaFourFiveSixAb()
	{
		return ApplyMetaValue(4, 5, 6, "ab") == 28;
	}

	/**
	 * Observe ApplyMetaValue with an empty label.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ApplyMetaValue(4, 5, 6, "")
	 * @Return true when the result is 26
	 * @Boundary empty label
	 */
	UFUNCTION()
	bool DisplayMetaEmptyLabel()
	{
		return ApplyMetaValue(4, 5, 6, "") == 26;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ACoverageMetaUFunctionMetaActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageMetaUFunctionMetaActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe the zero-scale and zero-input product boundaries.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ApplyMetaValue(4, 0, 6, "") and ApplyMetaValue(0, 5, 0, "")
	 * @Return true when the results are 6 and 0
	 * @Boundary zero scale and zero input
	 */
	UFUNCTION()
	bool DisplayMetaZeroScaleBoundary()
	{
		if (ApplyMetaValue(4, 0, 6, "") != 6)
		{
			return false;
		}
		return ApplyMetaValue(0, 5, 0, "") == 0;
	}
}
