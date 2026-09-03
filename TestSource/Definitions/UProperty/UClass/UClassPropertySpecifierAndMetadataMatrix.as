/**
 * UCLASS(Config=Game) specifier and metadata matrix including accessors. C++
 * verifies named members by path, so those UPROPERTY names are kept. The
 * observers cover a null NoClearActor and an empty FixedArray.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UClassPropertySpecifierAndMetadataMatrix
 * @Harness UClass
 * @Tag Definitions.UProperty.UClassPropertySpecifierAndMetadataMatrix
 * @Provenance Theme: Definitions.UProperty. WorldStory: UCLASS(Config=Game) specifier and metadata matrix including accessors.
 * @Provenance C++: CLASS_Config Game; Visible/Edit/NotEditable/Transient/SaveGame/meta DisplayName ClampMin ScriptName etc.
 * @Provenance Extra: NoClearActor defaults null; FixedArray empty; GetAccessorValue 20 / SetAccessorValue copy-independent.
 * @Provenance FixtureIsolated.
 */

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

	/**
	 * Blueprint getter for AccessorValue.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassPropertySpecifierAndMetadataMatrix
	 * @Inputs none
	 * @Return AccessorValue
	 */
	UFUNCTION(BlueprintPure)
	int GetAccessorValue() const
	{
		return AccessorValue;
	}

	/**
	 * Blueprint setter for AccessorValue.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassPropertySpecifierAndMetadataMatrix
	 * @Param NewValue written to AccessorValue
	 * @Inputs NewValue
	 * @Return void; AccessorValue is updated
	 */
	UFUNCTION(BlueprintCallable)
	void SetAccessorValue(int NewValue)
	{
		AccessorValue = NewValue;
	}

	/**
	 * Observe that NoClearActor defaults to null.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassPropertySpecifierAndMetadataMatrix
	 * @Inputs an unset AActor
	 * @Return true when the actor is null
	 * @Boundary null default
	 */
	UFUNCTION()
	bool SpecifierMatrixNullNoClearActor()
	{
		AActor NoClearActor;
		return NoClearActor == nullptr;
	}

	/**
	 * Observe that an empty FixedArray has Num 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassPropertySpecifierAndMetadataMatrix
	 * @Inputs a default-constructed TArray<int>
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int SpecifierMatrixEmptyFixedArrayNum()
	{
		TArray<int> FixedArray;
		return FixedArray.Num();
	}
}
