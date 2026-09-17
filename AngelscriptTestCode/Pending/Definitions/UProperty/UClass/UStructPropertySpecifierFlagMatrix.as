/**
 * @version v1
 * @summary USTRUCT specifier flags nested under an actor Data member. C++ verifies named members by path, so those UPROPERTY names are kept. The observers cover a null NoClearActor and an empty FixedArray.
 * @topic Definitions
 */
/**
 * @version root
 * @summary USTRUCT specifier flags nested under an actor Data member. C++ verifies named members by path, so those UPROPERTY names are kept. The observers cover a null NoClearActor and an empty FixedArray.
 * @topic Baseline
 */
UCLASS()
class UCoverageStructInstancedObject : UObject
{
	UPROPERTY()
	int Value = 0;
}

USTRUCT(BlueprintType)
struct FStructPropertySpecifierMatrix
{
	UPROPERTY(VisibleAnywhere)
	int VisibleValue = 1;

	UPROPERTY(VisibleDefaultsOnly)
	int VisibleDefaultValue = 2;

	UPROPERTY(VisibleInstanceOnly)
	int VisibleInstanceValue = 3;

	UPROPERTY(EditAnywhere)
	int EditAnywhereValue = 4;

	UPROPERTY(EditDefaultsOnly)
	int EditDefaultValue = 5;

	UPROPERTY(EditInstanceOnly)
	int EditInstanceValue = 6;

	UPROPERTY(NotEditable)
	int NotEditableValue = 7;

	UPROPERTY(EditConst)
	int EditConstValue = 8;

	UPROPERTY(AdvancedDisplay)
	int AdvancedValue = 9;

	UPROPERTY(Config)
	int ConfigValue = 10;

	UPROPERTY(AssetRegistrySearchable)
	int SearchableValue = 11;

	UPROPERTY(SkipSerialization)
	int SkipSerializedValue = 12;

	UPROPERTY(NoClear)
	AActor NoClearActor;

	UPROPERTY(Transient)
	int TransientValue = 13;

	UPROPERTY(SaveGame)
	int SaveGameValue = 14;

	UPROPERTY(EditFixedSize)
	TArray<int> FixedArray;

	UPROPERTY(Instanced)
	UCoverageStructInstancedObject InlineObject;
}

UCLASS()
class ACoverageStructPropertySpecifierActor : AActor
{
	UPROPERTY()
	FStructPropertySpecifierMatrix Data;

	/**
	 * Observe that NoClearActor defaults to null.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UStructPropertySpecifierFlagMatrix
	 * @Inputs an unset AActor
	 * @Return true when the actor is null
	 * @Boundary null default
	 */
	UFUNCTION()
	bool StructSpecifierNullNoClearActor()
	{
		AActor NoClearActor;
		return NoClearActor == nullptr;
	}

	/**
	 * Observe that an empty FixedArray has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UStructPropertySpecifierFlagMatrix
	 * @Inputs a default-constructed TArray<int>
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int StructSpecifierEmptyFixedArrayNum()
	{
		TArray<int> FixedArray;
		return FixedArray.Num();
	}
}
/** @end */
