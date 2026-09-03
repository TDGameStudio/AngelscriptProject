/**
 * BlueprintOverride out-param plus Super writeback. C++ verifies
 * ComputeOutValue(20,"abc") return 51 out 27, DispatchOutValue(15,"abcd") return
 * 43 out 23, and BaseCallCount==2 ChildCallCount==2. Input 0 / empty Label is the
 * Super path boundary.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.BlueprintOverrideOutParameterAndSuperMatrix
 * @Harness UClass
 * @Tag Feature.Inheritance.BlueprintOverrideOutParameterAndSuperMatrix
 * @Provenance Theme: Feature.Inheritance. WorldStory BlueprintOverride out-param + Super writeback.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintOverrideOutParameterAndSuperMatrix
 * @Provenance Oracle: ComputeOutValue(20,"abc") return 51 out 27; DispatchOutValue(15,"abcd") return 43 out 23;
 * @Provenance BaseCallCount==2, ChildCallCount==2.
 * @Provenance Extra: empty handle null; Input 0 / empty Label Super path. FixtureIsolated.
 * @Provenance Keep BaseCallCount/ChildCallCount/LastOutValue.
 */

UCLASS()
class ACoverageUFunctionOutOverrideBase : AActor
{
	UPROPERTY()
	int BaseCallCount = 0;

	UPROPERTY()
	int ChildCallCount = 0;

	UPROPERTY()
	int LastOutValue = 0;

	/**
	 * Parent BlueprintEvent that writes OutValue = Input + Label.Len() and returns OutValue + 1.
	 *
	 * @Kind Action
	 * @Covers Inheritance.BlueprintOverrideOutParameterAndSuperMatrix
	 * @Inputs Input, Label and an out parameter
	 * @Return OutValue + 1; OutValue = Input + Label.Len()
	 * @Param Input the base value
	 * @Param Label length added to OutValue
	 * @Param OutValue written by the parent body
	 */
	UFUNCTION(BlueprintEvent, BlueprintCallable, Category="Coverage|OutOverride", meta=(AdvancedDisplay="Label", DisplayName="Compute Out Value"))
	int ComputeOutValue(int Input, FString Label, int&out OutValue)
	{
		BaseCallCount += 1;
		OutValue = Input + Label.Len();
		LastOutValue = OutValue;
		return OutValue + 1;
	}

	/**
	 * Dispatch through the virtual ComputeOutValue so the child override is hit.
	 *
	 * @Kind Action
	 * @Covers Inheritance.BlueprintOverrideOutParameterAndSuperMatrix
	 * @Inputs Input, Label and an out parameter
	 * @Return ComputeOutValue(Input, Label, OutValue)
	 * @Param Input the base value
	 * @Param Label forwarded to ComputeOutValue
	 * @Param OutValue forwarded to ComputeOutValue
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|OutOverride")
	int DispatchOutValue(int Input, FString Label, int&out OutValue)
	{
		return ComputeOutValue(Input, Label, OutValue);
	}
}

UCLASS()
class ACoverageUFunctionOutOverrideChild : ACoverageUFunctionOutOverrideBase
{
	/**
	 * Child BlueprintOverride that Super-calls then adds 4 to the parent out value.
	 *
	 * @Kind Action
	 * @Covers Inheritance.BlueprintOverrideOutParameterAndSuperMatrix
	 * @Inputs Input, Label and an out parameter
	 * @Return ParentReturn + OutValue; OutValue = ParentOut + 4
	 * @Param Input the base value
	 * @Param Label forwarded to Super::ComputeOutValue
	 * @Param OutValue written as ParentOut + 4
	 */
	UFUNCTION(BlueprintOverride)
	int ComputeOutValue(int Input, FString Label, int&out OutValue)
	{
		ChildCallCount += 1;

		int ParentOut = 0;
		int ParentReturn = Super::ComputeOutValue(Input, Label, ParentOut);
		OutValue = ParentOut + 4;
		LastOutValue = OutValue;
		return ParentReturn + OutValue;
	}

	/**
	 * Observe ComputeOutValue(20, "abc") return 51.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideOutParameterAndSuperMatrix
	 * @Inputs ComputeOutValue(20, "abc", OutValue)
	 * @Return 51
	 */
	UFUNCTION()
	int DirectReturn()
	{
		int OutValue = 0;
		return ComputeOutValue(20, "abc", OutValue);
	}

	/**
	 * Observe ComputeOutValue(20, "abc") writing out 27.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideOutParameterAndSuperMatrix
	 * @Inputs ComputeOutValue(20, "abc", OutValue)
	 * @Return OutValue, expected to be 27
	 */
	UFUNCTION()
	int DirectOut()
	{
		int OutValue = 0;
		ComputeOutValue(20, "abc", OutValue);
		return OutValue;
	}

	/**
	 * Observe DispatchOutValue(15, "abcd") return 43.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideOutParameterAndSuperMatrix
	 * @Inputs DispatchOutValue(15, "abcd", OutValue)
	 * @Return 43
	 */
	UFUNCTION()
	int DispatchReturn()
	{
		int OutValue = 0;
		return DispatchOutValue(15, "abcd", OutValue);
	}

	/**
	 * Observe DispatchOutValue(15, "abcd") writing out 23.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideOutParameterAndSuperMatrix
	 * @Inputs DispatchOutValue(15, "abcd", OutValue)
	 * @Return OutValue, expected to be 23
	 */
	UFUNCTION()
	int DispatchOut()
	{
		int OutValue = 0;
		DispatchOutValue(15, "abcd", OutValue);
		return OutValue;
	}

	/**
	 * Observe ComputeOutValue(0, "") writing the Super path boundary.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.BlueprintOverrideOutParameterAndSuperMatrix
	 * @Inputs ComputeOutValue(0, "", OutValue)
	 * @Return OutValue, expected to be 4
	 * @Boundary zero input and empty label
	 */
	UFUNCTION()
	int ZeroInputEmptyLabelOut()
	{
		int OutValue = 0;
		ComputeOutValue(0, "", OutValue);
		return OutValue;
	}
}
