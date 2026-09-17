/**
 * @version v1
 * @summary An int specifier and Clamp/UI/EditCondition/Category metadata matrix. C++ verifies named properties by path, so those UPROPERTY names are kept. The observers cover the empty 0 default and that EmptyInt is independent of.
 * @topic Definitions
 */
/**
 * @version root
 * @summary An int specifier and Clamp/UI/EditCondition/Category metadata matrix. C++ verifies named properties by path, so those UPROPERTY names are kept. The observers cover the empty 0 default and that EmptyInt is independent of.
 * @topic Baseline
 */
UCLASS()
class ACoverageIntSpecifierActor : AActor
{
	UPROPERTY(EditAnywhere)
	int EditAnywhereInt = 1;

	UPROPERTY(EditDefaultsOnly)
	int EditDefaultsOnlyInt = 2;

	UPROPERTY(EditInstanceOnly)
	int EditInstanceOnlyInt = 3;

	UPROPERTY(NotEditable)
	int NotEditableInt = 4;

	UPROPERTY(EditConst)
	int EditConstInt = 5;

	UPROPERTY(VisibleAnywhere)
	int VisibleAnywhereInt = 6;

	UPROPERTY(VisibleDefaultsOnly)
	int VisibleDefaultsOnlyInt = 7;

	UPROPERTY(VisibleInstanceOnly)
	int VisibleInstanceOnlyInt = 8;

	UPROPERTY(BlueprintReadWrite)
	int BlueprintReadWriteInt = 9;

	UPROPERTY(BlueprintReadOnly)
	int BlueprintReadOnlyInt = 10;

	UPROPERTY(BlueprintHidden)
	int BlueprintHiddenInt = 11;

	UPROPERTY(Transient)
	int TransientInt = 12;

	UPROPERTY(Config)
	int ConfigInt = 13;

	UPROPERTY(SaveGame)
	int SaveGameInt = 14;

	UPROPERTY(AdvancedDisplay)
	int AdvancedDisplayInt = 15;

	UPROPERTY(Interp)
	int InterpInt = 16;

	UPROPERTY(ExposeOnSpawn)
	int ExposeOnSpawnInt = 17;

	UPROPERTY(meta = (ClampMin = "0", ClampMax = "10"))
	int ClampedInt = 5;

	UPROPERTY(meta = (UIMin = "1", UIMax = "5"))
	int UIRangedInt = 3;

	UPROPERTY()
	bool Gate = true;

	UPROPERTY(meta = (EditCondition = "Gate"))
	int EditConditionInt = 18;

	UPROPERTY(Category = "Stats")
	int CategorizedInt = 19;

	UPROPERTY(EditAnywhere, BlueprintReadOnly)
	int EditableReadOnlyInt = 20;

	UPROPERTY(EditDefaultsOnly, BlueprintReadOnly, Transient, Category = "Tuning")
	int ComboInt = 21;

	UPROPERTY()
	int EmptyInt = 0;

	/**
	 * Observe the empty int default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.IntPropertySpecifierFlags
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int IntSpecifierEmptyDefault()
	{
		return 0;
	}

	/**
	 * Observe that EmptyInt is independent of EditAnywhereInt.
	 *
	 * @Kind Observe
	 * @Covers UProperty.IntPropertySpecifierFlags
	 * @Inputs local EditAnywhereInt 1 and EmptyInt 0
	 * @Return true when the two locals differ
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool IntSpecifierEmptyIndependentOfEditAnywhere()
	{
		int EditAnywhereInt = 1;
		int EmptyInt = 0;
		return EditAnywhereInt != EmptyInt;
	}
}
/** @end */
