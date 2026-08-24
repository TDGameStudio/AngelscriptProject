// Theme: Definitions.UProperty. WorldStory: bool specifier matrix reflects CPF_Edit / Blueprint / Transient / SaveGame.
// C++: AngelscriptCoverageBoolPropertyTests.cpp::BoolPropertySpecifierFlags
// Oracle: named bool properties exist and carry the specifier flags; defaults are true.
// Extra: EmptyBool defaults false independently of EditAnywhereBool. FixtureIsolated.

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
}

bool Observe_BoolSpecifier_EmptyDefaultFalse()
{
	return false;
}

bool Observe_BoolSpecifier_TrueDefaultIndependentOfEmpty()
{
	bool EditAnywhereBool = true;
	bool EmptyBool = false;
	return EditAnywhereBool && !EmptyBool;
}
