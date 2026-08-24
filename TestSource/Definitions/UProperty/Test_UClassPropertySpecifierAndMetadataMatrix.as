// Theme: Definitions.UProperty. WorldStory: UCLASS(Config=Game) specifier and metadata matrix including accessors.
// C++: CLASS_Config Game; Visible/Edit/NotEditable/Transient/SaveGame/meta DisplayName ClampMin ScriptName etc.
// Extra: NoClearActor defaults null; FixedArray empty; GetAccessorValue 20 / SetAccessorValue copy-independent.
// FixtureIsolated.

UCLASS(Config=Game)
class ACoverageUClassPropertySpecifierActor : AActor
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

	UPROPERTY(NotVisible)
	int NotVisibleValue = 21;

	UPROPERTY(NotEditable)
	int NotEditableValue = 7;

	UPROPERTY(EditConst)
	int EditConstValue = 8;

	UPROPERTY(AdvancedDisplay)
	int AdvancedValue = 9;

	UPROPERTY(Interp)
	float InterpValue = 9.5f;

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

	UPROPERTY(EditInline)
	UObject EditInlineObject;

	UPROPERTY(BindWidget)
	UObject BoundWidget;

	UPROPERTY(ExposeOnSpawn)
	int SpawnExposedValue = 15;

	UPROPERTY(meta=(EditorOnly))
	int EditorOnlyValue = 16;

	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="Coverage|Member", meta=(DisplayName="Editable Count", ToolTip="Editable count tooltip", ClampMin="0", ClampMax="100"))
	int EditableCount = 19;

	UPROPERTY(EditAnywhere, meta=(ScriptName="AliasCount"))
	int NativeCount = 27;

	UPROPERTY(EditAnywhere, meta=(ScriptName="AliasLabel", DeprecatedProperty, DeprecationMessage="Use AliasLabel instead"))
	FString NativeLabel = "AliasDefault";

	UPROPERTY(EditAnywhere, meta=(InlineEditConditionToggle))
	bool bSpecifierToggle = true;

	UPROPERTY(EditAnywhere, meta=(EditCondition="bSpecifierToggle"))
	int EditConditionValue = 24;

	UPROPERTY(EditAnywhere, meta=(EditCondition="bSpecifierToggle", EditConditionHides))
	int EditConditionHiddenValue = 28;

	UPROPERTY(EditAnywhere, meta=(UIMin="0.0", UIMax="100.0", Units="Seconds"))
	float TimedValue = 1.5f;

	UPROPERTY(EditAnywhere, meta=(MakeEditWidget))
	FVector WidgetLocation = FVector(1, 2, 3);

	UPROPERTY(EditAnywhere, meta=(NoResetToDefault))
	int NoResetValue = 25;

	UPROPERTY(EditAnywhere, meta=(DeprecatedProperty, DeprecationMessage="Use EditableCount instead"))
	int DeprecatedValue = 26;

	UPROPERTY(EditAnywhere, meta=(DisplayAfter="EditableCount", DisplayPriority="2", ShortToolTip="Ordered short tooltip", CoverageAdvancedKey="OrderedValue", ConfigRestartRequired="true"))
	int OrderedMetadataValue = 29;

	UPROPERTY(BlueprintHidden)
	int BlueprintHiddenValue = 22;

	UPROPERTY(BlueprintProtected)
	int BlueprintProtectedValue = 23;

	UPROPERTY(BlueprintReadWrite, BlueprintGetter=GetAccessorValue, BlueprintSetter=SetAccessorValue)
	int AccessorValue = 20;

	UFUNCTION(BlueprintPure)
	int GetAccessorValue() const
	{
		return AccessorValue;
	}

	UFUNCTION(BlueprintCallable)
	void SetAccessorValue(int NewValue)
	{
		AccessorValue = NewValue;
	}
}

bool Observe_SpecifierMatrix_NullNoClearActor()
{
	AActor NoClearActor;
	return NoClearActor == nullptr;
}

int Observe_SpecifierMatrix_EmptyFixedArrayNum()
{
	TArray<int> FixedArray;
	return FixedArray.Num();
}
