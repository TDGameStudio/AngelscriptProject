// Theme: Definitions.UProperty. WorldStory: USTRUCT specifier flags nested under an actor Data member.
// C++: Data is a generated struct property; Visible/Edit/NotEditable/Transient/SaveGame/Instanced members reflect.
// Extra: NoClearActor null; FixedArray empty; InlineObject Value 0. FixtureIsolated.

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
}

bool Observe_StructSpecifier_NullNoClearActor()
{
	AActor NoClearActor;
	return NoClearActor == nullptr;
}

int Observe_StructSpecifier_EmptyFixedArrayNum()
{
	TArray<int> FixedArray;
	return FixedArray.Num();
}
