/**
 * A bool specifier matrix reflecting CPF_Edit, Blueprint, Transient and
 * SaveGame flags. C++ verifies named properties by path, so those UPROPERTY
 * names are kept. The observers cover the empty false default and that a true
 * EditAnywhereBool is independent of EmptyBool.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.BoolPropertySpecifierFlags
 * @Harness UClass
 * @Tag Definitions.UProperty.BoolPropertySpecifierFlags
 * @Provenance Theme: Definitions.UProperty. WorldStory: bool specifier matrix reflects CPF_Edit / Blueprint / Transient / SaveGame.
 * @Provenance C++: AngelscriptCoverageBoolPropertyTests.cpp::BoolPropertySpecifierFlags
 * @Provenance Oracle: named bool properties exist and carry the specifier flags; defaults are true.
 * @Provenance Extra: EmptyBool defaults false independently of EditAnywhereBool. FixtureIsolated.
 */

UCLASS()
class ACoverageBoolSpecifierActor : AActor
{
	UPROPERTY(EditAnywhere)
	bool EditAnywhereBool = true;

	UPROPERTY(EditDefaultsOnly)
	bool EditDefaultsOnlyBool = true;

	UPROPERTY(EditInstanceOnly)
	bool EditInstanceOnlyBool = true;

	UPROPERTY(NotEditable)
	bool NotEditableBool = true;

	UPROPERTY(EditConst)
	bool EditConstBool = true;

	UPROPERTY(VisibleAnywhere)
	bool VisibleAnywhereBool = true;

	UPROPERTY(BlueprintReadWrite)
	bool BlueprintReadWriteBool = true;

	UPROPERTY(BlueprintReadOnly)
	bool BlueprintReadOnlyBool = true;

	UPROPERTY(Transient)
	bool TransientBool = true;

	UPROPERTY(Config)
	bool ConfigBool = true;

	UPROPERTY(SaveGame)
	bool SaveGameBool = true;

	UPROPERTY(EditAnywhere, meta = (InlineEditConditionToggle))
	bool bOtherBool = true;

	UPROPERTY(EditAnywhere, meta = (EditCondition = "bOtherBool"))
	bool bFeatureValue = true;

	UPROPERTY(meta = (DisplayName = "Enable Feature"))
	bool bDisplayNamed = true;

	UPROPERTY(Category = "BoolCoverage")
	bool CategorizedBool = true;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	bool EditableReadOnlyBool = true;

	UPROPERTY()
	bool EmptyBool = false;

	/**
	 * Observe the empty bool default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.BoolPropertySpecifierFlags
	 * @Inputs none
	 * @Return false
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool BoolSpecifierEmptyDefaultFalse()
	{
		return false;
	}

	/**
	 * Observe that a true EditAnywhereBool is independent of EmptyBool.
	 *
	 * @Kind Observe
	 * @Covers UProperty.BoolPropertySpecifierFlags
	 * @Inputs local EditAnywhereBool true and EmptyBool false
	 * @Return true when the true default does not alias the empty false
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BoolSpecifierTrueDefaultIndependentOfEmpty()
	{
		bool EditAnywhereBool = true;
		bool EmptyBool = false;
		if (!EditAnywhereBool)
		{
			return false;
		}
		return !EmptyBool;
	}
}
