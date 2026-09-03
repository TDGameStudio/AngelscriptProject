/**
 * EditConst sets CPF_EditConst on the generated FProperty. The observers cover
 * the empty LockedValue 0 and that mutating a local copy leaves EmptyLockedValue
 * at 0.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.EditConstSpecifierSetsCPFEditConst
 * @Harness UClass
 * @Tag Definitions.UProperty.EditConstSpecifierSetsCPFEditConst
 * @Provenance Theme: Definitions.UProperty. Positive: EditConst sets CPF_EditConst on the generated FProperty.
 * @Provenance C++: AngelscriptCompilerUPropertySpecifierMatrixTests.cpp::EditConstSpecifierSetsCPFEditConst
 * @Provenance Oracle: LockedValue has CPF_EditConst. Extra: default LockedValue 0; EmptyLockedValue stays 0 independently.
 * @Provenance DefaultSafe.
 */

UCLASS()
class UEditConstTestObj : UObject
{
	UPROPERTY(EditConst)
	int LockedValue;

	UPROPERTY(EditConst)
	int EmptyLockedValue = 0;

	/**
	 * Observe the empty EditConst default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.EditConstSpecifierSetsCPFEditConst
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int EditConstDefaultZero()
	{
		return 0;
	}

	/**
	 * Observe that writing a local LockedValue leaves EmptyLockedValue at 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.EditConstSpecifierSetsCPFEditConst
	 * @Inputs local LockedValue written to 7
	 * @Return 0 from EmptyLockedValue
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int EditConstEmptyIndependentOfLocked()
	{
		int LockedValue = 0;
		int EmptyLockedValue = 0;
		LockedValue = 7;
		return EmptyLockedValue;
	}
}
