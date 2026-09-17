/**
 * @version v1
 * @summary Specifier metadata plus a const getter and Exec. SetStoredValue writes StoredValue, GetStoredValue and ReadValue return it, and CoverageConsoleCommand writes 77. StoredValue defaults to 5, a nullptr actor is the empty.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Specifier metadata plus a const getter and Exec. SetStoredValue writes StoredValue, GetStoredValue and ReadValue return it, and CoverageConsoleCommand writes 77. StoredValue defaults to 5, a nullptr actor is the empty.
 * @topic Baseline
 */
UCLASS()
class ACoverageMacrosFunctionSpecifiersActor : AActor
{
	UPROPERTY()
	int StoredValue = 5;

	/**
	 * Write StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value New StoredValue
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION()
	void SetStoredValue(int Value)
	{
		StoredValue = Value;
	}

	/**
	 * Const getter for StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StoredValue
	 * @Return the current StoredValue
	 */
	UFUNCTION()
	int GetStoredValue() const
	{
		return StoredValue;
	}

	/**
	 * Metadata-rich action that writes RequiredValue + OptionalValue + Label.Len(), plus 1 if Target is live.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Target WorldContext / DefaultToSelf / HidePin object
	 * @Param RequiredValue Required addend
	 * @Param OptionalValue AdvancedDisplay addend
	 * @Param OptionalLabel AdvancedDisplay string received as const FString&in
	 * @Inputs Target, RequiredValue, OptionalValue, OptionalLabel
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Functions", CallInEditor, meta=(
		DisplayName="Visible Coverage Action",
		Keywords="coverage macro function",
		ToolTip="Full function tooltip",
		ShortToolTip="Short function tooltip",
		CompactNodeTitle="ACT",
		AdvancedDisplay="OptionalValue,OptionalLabel",
		WorldContext="Target",
		DefaultToSelf="Target",
		HidePin="Target",
		AutoCreateRefTerm="OptionalLabel"))
	void VisibleAction(UObject Target, int RequiredValue, int OptionalValue, const FString&in OptionalLabel)
	{
		StoredValue = RequiredValue + OptionalValue + OptionalLabel.Len();
		if (Target != nullptr)
		{
			StoredValue += 1;
		}
	}

	/**
	 * BlueprintPure getter for StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StoredValue
	 * @Return the current StoredValue
	 */
	UFUNCTION(BlueprintPure, Category="Coverage|Functions", meta=(DisplayName="Read Coverage Value"))
	int ReadValue() const
	{
		return StoredValue;
	}

	/**
	 * Exec command that writes StoredValue to 77.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs none
	 * @Return void; StoredValue becomes 77
	 */
	UFUNCTION(Exec, Category="Coverage|Console")
	void CoverageConsoleCommand()
	{
		StoredValue = 77;
	}

	/**
	 * Observe the default StoredValue of 5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a freshly constructed actor
	 * @Return true when GetStoredValue and ReadValue are 5
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFive()
	{
		if (GetStoredValue() != 5)
		{
			return false;
		}
		return ReadValue() == 5;
	}

	/**
	 * Observe VisibleAction with a null Target and empty label.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs VisibleAction(nullptr, 0, 0, "")
	 * @Return true when StoredValue and ReadValue are 0
	 * @Boundary null target and empty label
	 */
	UFUNCTION()
	bool NullTargetEmptyLabel()
	{
		VisibleAction(nullptr, 0, 0, "");
		if (StoredValue != 0)
		{
			return false;
		}
		return ReadValue() == 0;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ACoverageMacrosFunctionSpecifiersActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageMacrosFunctionSpecifiersActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe SetStoredValue(11) then CoverageConsoleCommand writing 77.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs SetStoredValue(11) then CoverageConsoleCommand()
	 * @Return true when the exec write lands at 77
	 */
	UFUNCTION()
	bool ExecBoundary()
	{
		SetStoredValue(11);
		if (GetStoredValue() != 11)
		{
			return false;
		}
		CoverageConsoleCommand();
		if (StoredValue != 77)
		{
			return false;
		}
		return ReadValue() == 77;
	}
}
/** @end */
