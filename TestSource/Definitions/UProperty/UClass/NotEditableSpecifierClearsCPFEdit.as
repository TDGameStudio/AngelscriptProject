/**
 * NotEditable clears CPF_Edit on the generated FProperty. The observers cover
 * the empty HiddenValue 0 and that mutating a local copy leaves EmptyHiddenValue
 * at 0.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.NotEditableSpecifierClearsCPFEdit
 * @Harness UClass
 * @Tag Definitions.UProperty.NotEditableSpecifierClearsCPFEdit
 * @Provenance Theme: Definitions.UProperty. Positive: NotEditable clears CPF_Edit on the generated FProperty.
 * @Provenance C++: AngelscriptCompilerUPropertySpecifierMatrixTests.cpp::NotEditableSpecifierClearsCPFEdit
 * @Provenance Oracle: HiddenValue does not have CPF_Edit. Extra: default HiddenValue 0; EmptyHiddenValue stays 0.
 * @Provenance DefaultSafe.
 */

UCLASS()
class UNotEditableTestObj : UObject
{
	UPROPERTY(NotEditable)
	int HiddenValue;

	UPROPERTY(NotEditable)
	int EmptyHiddenValue = 0;

	/**
	 * Observe the empty NotEditable default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.NotEditableSpecifierClearsCPFEdit
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int NotEditableDefaultZero()
	{
		return 0;
	}

	/**
	 * Observe that writing a local HiddenValue leaves EmptyHiddenValue at 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.NotEditableSpecifierClearsCPFEdit
	 * @Inputs local HiddenValue written to 9
	 * @Return 0 from EmptyHiddenValue
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int NotEditableEmptyIndependentOfHidden()
	{
		int HiddenValue = 0;
		int EmptyHiddenValue = 0;
		HiddenValue = 9;
		return EmptyHiddenValue;
	}
}
