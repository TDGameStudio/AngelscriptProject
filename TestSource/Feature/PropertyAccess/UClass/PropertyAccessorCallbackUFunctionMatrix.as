/**
 * BlueprintGetter/Setter UFUNCTION matrix on AccessorValue and ReadonlyValue.
 * C++ spawns and checks GetAccessorValue==20; SetAccessorValue(35) then Get==35,
 * SetterCallCount==1, GetReadonlyValue==42 (7+35). Keep AccessorValue /
 * ReadonlyValue / SetterCallCount.
 *
 * @Theme Feature.PropertyAccess
 * @Subject PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
 * @Harness UClass
 * @Tag Feature.PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
 * @Provenance Theme: Feature.PropertyAccess. WorldStory BlueprintGetter/Setter UFUNCTION matrix.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::PropertyAccessorCallbackUFunctionMatrix
 * @Provenance Spawn + GetAccessorValue==20; SetAccessorValue(35) then Get==35,
 * @Provenance SetterCallCount==1, GetReadonlyValue==42 (7+35).
 * @Provenance Extra: default SetterCallCount 0; GetReadonlyValue default 27; Set 0.
 * @Provenance FixtureIsolated. Keep AccessorValue / ReadonlyValue / SetterCallCount.
 */

UCLASS()
class ACoverageUFunctionAccessorActor : AActor
{
	UPROPERTY(BlueprintReadWrite, BlueprintGetter=GetAccessorValue, BlueprintSetter=SetAccessorValue)
	int AccessorValue = 20;

	UPROPERTY(BlueprintReadOnly, BlueprintGetter=GetReadonlyValue)
	int ReadonlyValue = 7;

	UPROPERTY()
	int SetterCallCount = 0;

	/**
	 * BlueprintGetter for AccessorValue. Returns the stored accessor integer.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
	 * @Inputs none
	 * @Return the current AccessorValue
	 */
	UFUNCTION(BlueprintPure, Category="Coverage|Accessor")
	int GetAccessorValue() const
	{
		return AccessorValue;
	}

	/**
	 * BlueprintSetter for AccessorValue. Increments SetterCallCount then stores NewValue.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
	 * @Inputs the value to store
	 * @Return void; AccessorValue is NewValue and SetterCallCount is increased by 1
	 * @Param NewValue the value to store
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Accessor")
	void SetAccessorValue(int NewValue)
	{
		SetterCallCount += 1;
		AccessorValue = NewValue;
	}

	/**
	 * BlueprintGetter for ReadonlyValue. Returns ReadonlyValue plus AccessorValue.
	 *
	 * @Kind WorldStory
	 * @Covers PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
	 * @Inputs none
	 * @Return ReadonlyValue + AccessorValue
	 */
	UFUNCTION(BlueprintPure, Category="Coverage|Accessor")
	int GetReadonlyValue() const
	{
		return ReadonlyValue + AccessorValue;
	}

	/**
	 * Observe the default GetAccessorValue before any setter.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
	 * @Inputs AccessorValue at its default 20
	 * @Return 20
	 */
	UFUNCTION()
	int Accessor_DefaultGet()
	{
		return GetAccessorValue();
	}

	/**
	 * Observe SetAccessorValue(35) then GetAccessorValue.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
	 * @Inputs SetAccessorValue(35)
	 * @Return 35
	 */
	UFUNCTION()
	int Accessor_SetThenGet()
	{
		SetAccessorValue(35);
		return GetAccessorValue();
	}

	/**
	 * Observe SetterCallCount after one SetAccessorValue(35).
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
	 * @Inputs SetAccessorValue(35)
	 * @Return 1
	 */
	UFUNCTION()
	int Accessor_SetterCallCount()
	{
		SetAccessorValue(35);
		return SetterCallCount;
	}

	/**
	 * Observe GetReadonlyValue after SetAccessorValue(35): 7+35.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
	 * @Inputs SetAccessorValue(35)
	 * @Return 42
	 */
	UFUNCTION()
	int Accessor_ReadonlyAfterSet()
	{
		SetAccessorValue(35);
		return GetReadonlyValue();
	}

	/**
	 * Observe the default SetterCallCount before any setter.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
	 * @Inputs none
	 * @Return 0
	 * @Boundary default SetterCallCount
	 */
	UFUNCTION()
	int Accessor_DefaultSetterCount()
	{
		return SetterCallCount;
	}

	/**
	 * Observe SetAccessorValue(0) as a zero boundary.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
	 * @Inputs SetAccessorValue(0)
	 * @Return 0
	 * @Boundary Set 0
	 */
	UFUNCTION()
	int Accessor_ZeroBoundary()
	{
		SetAccessorValue(0);
		return GetAccessorValue();
	}

	/**
	 * Observe the default GetReadonlyValue: 7+20.
	 *
	 * @Kind Observe
	 * @Covers PropertyAccess.PropertyAccessorCallbackUFunctionMatrix
	 * @Inputs none
	 * @Return 27
	 * @Boundary default GetReadonlyValue
	 */
	UFUNCTION()
	int Accessor_DefaultReadonly()
	{
		return GetReadonlyValue();
	}
}
