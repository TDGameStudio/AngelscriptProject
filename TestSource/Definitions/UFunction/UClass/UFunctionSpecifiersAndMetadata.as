/**
 * BlueprintCallable, BlueprintPure, and Exec plus DisplayName metadata.
 * VisibleAction writes StoredValue, ReadStoredValue returns it, and
 * CoverageExecCommand writes 77. StoredValue defaults to 0, a nullptr actor
 * is the empty handle, and VisibleAction(0) is the empty write.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UFunctionSpecifiersAndMetadata
 * @Harness UClass
 * @Tag Definitions.UFunction.UFunctionSpecifiersAndMetadata
 * @Provenance Theme: Definitions.UFunction. WorldStory BlueprintCallable/Pure/Exec plus DisplayName metadata.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::UFunctionSpecifiersAndMetadata
 * @Provenance Oracle: VisibleAction writes StoredValue; ReadStoredValue returns it; CoverageExecCommand writes 77.
 * @Provenance Extra: StoredValue default 0; nullptr actor is the empty handle; VisibleAction(0) empty write.
 * @Provenance FixtureIsolated. Keep StoredValue name.
 */

UCLASS()
class ACoverageUFunctionSpecifiersActor : AActor
{
	UPROPERTY()
	int StoredValue = 0;

	/**
	 * BlueprintCallable action that writes StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value New StoredValue
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Functions", CallInEditor, meta=(DisplayName="Visible Action", Keywords="coverage keyword action", ToolTip="Function tooltip text", ShortToolTip="Short function tooltip", CompactNodeTitle="ACT"))
	void VisibleAction(int Value)
	{
		StoredValue = Value;
	}

	/**
	 * BlueprintPure getter for StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StoredValue
	 * @Return the current StoredValue
	 */
	UFUNCTION(BlueprintPure, Category="Coverage|Functions", meta=(DisplayName="Read Stored Value"))
	int ReadStoredValue() const
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
	void CoverageExecCommand()
	{
		StoredValue = 77;
	}

	/**
	 * Observe the default StoredValue of 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a freshly constructed actor
	 * @Return true when ReadStoredValue and StoredValue are 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool EmptyDefaultIsZero()
	{
		if (ReadStoredValue() != 0)
		{
			return false;
		}
		return StoredValue == 0;
	}

	/**
	 * Observe VisibleAction at the zero write.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs VisibleAction(0)
	 * @Return true when ReadStoredValue is 0
	 * @Boundary zero write
	 */
	UFUNCTION()
	bool ZeroWrite()
	{
		VisibleAction(0);
		return ReadStoredValue() == 0;
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs ACoverageUFunctionSpecifiersActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageUFunctionSpecifiersActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe VisibleAction(11) then CoverageExecCommand writing 77.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs VisibleAction(11) then CoverageExecCommand()
	 * @Return true when the exec write lands at 77
	 */
	UFUNCTION()
	bool ExecBoundary()
	{
		VisibleAction(11);
		if (ReadStoredValue() != 11)
		{
			return false;
		}
		CoverageExecCommand();
		if (ReadStoredValue() != 77)
		{
			return false;
		}
		return StoredValue == 77;
	}
}
