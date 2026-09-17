/**
 * @version v1
 * @summary Last specifier wins for BlueprintCallable and BlueprintPure. CallableThenHidden(10) writes 11, HiddenThenCallable(20) writes 22, HiddenExecCommand(30) writes 35, PureThenHidden(4) is 42, HiddenThenPure(5) is 44. Default.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Last specifier wins for BlueprintCallable and BlueprintPure. CallableThenHidden(10) writes 11, HiddenThenCallable(20) writes 22, HiddenExecCommand(30) writes 35, PureThenHidden(4) is 42, HiddenThenPure(5) is 44. Default.
 * @topic Baseline
 */
UCLASS()
class ACoverageUFunctionCallableOrderActor : AActor
{
	UPROPERTY()
	int StoredValue = 0;

	/**
	 * BlueprintCallable then NotBlueprintCallable writes Value + 1.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Seed
	 * @Inputs Value
	 * @Return void; StoredValue becomes Value + 1
	 */
	UFUNCTION(BlueprintCallable, NotBlueprintCallable, Category="Coverage|CallableOrder")
	void CallableThenHidden(int Value)
	{
		StoredValue = Value + 1;
	}

	/**
	 * NotBlueprintCallable then BlueprintCallable writes Value + 2.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Seed
	 * @Inputs Value
	 * @Return void; StoredValue becomes Value + 2
	 */
	UFUNCTION(NotBlueprintCallable, BlueprintCallable, Category="Coverage|CallableOrder")
	void HiddenThenCallable(int Value)
	{
		StoredValue = Value + 2;
	}

	/**
	 * BlueprintPure then NotBlueprintCallable returns StoredValue + Value + 3.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Addend
	 * @Inputs Value
	 * @Return StoredValue + Value + 3
	 */
	UFUNCTION(BlueprintPure, NotBlueprintCallable, Category="Coverage|CallableOrder")
	int PureThenHidden(int Value) const
	{
		return StoredValue + Value + 3;
	}

	/**
	 * NotBlueprintCallable then BlueprintPure returns StoredValue + Value + 4.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Addend
	 * @Inputs Value
	 * @Return StoredValue + Value + 4
	 */
	UFUNCTION(NotBlueprintCallable, BlueprintPure, Category="Coverage|CallableOrder")
	int HiddenThenPure(int Value) const
	{
		return StoredValue + Value + 4;
	}

	/**
	 * Hidden Exec command that writes Value + 5.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Value Seed
	 * @Inputs Value
	 * @Return void; StoredValue becomes Value + 5
	 */
	UFUNCTION(NotBlueprintCallable, Exec, Category="Coverage|CallableOrder")
	void HiddenExecCommand(int Value)
	{
		StoredValue = Value + 5;
	}

	/**
	 * Read StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs StoredValue
	 * @Return the current StoredValue
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|CallableOrder")
	int ReadStoredValue() const
	{
		return StoredValue;
	}

	/**
	 * Observe CallableThenHidden(10), HiddenThenCallable(20), HiddenExecCommand(30).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs the void sequence 10, 20, 30
	 * @Return 35, or a negative sentinel if an intermediate value is wrong
	 */
	UFUNCTION()
	int VoidSequence()
	{
		CallableThenHidden(10);
		if (ReadStoredValue() != 11)
		{
			return -1;
		}
		HiddenThenCallable(20);
		if (ReadStoredValue() != 22)
		{
			return -2;
		}
		HiddenExecCommand(30);
		return ReadStoredValue();
	}

	/**
	 * Observe PureThenHidden(4) after HiddenExecCommand(30).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs HiddenExecCommand(30) then PureThenHidden(4)
	 * @Return 42
	 */
	UFUNCTION()
	int PureAfterExec()
	{
		HiddenExecCommand(30);
		return PureThenHidden(4);
	}

	/**
	 * Observe HiddenThenPure(5) after HiddenExecCommand(30).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs HiddenExecCommand(30) then HiddenThenPure(5)
	 * @Return 44
	 */
	UFUNCTION()
	int HiddenThenPureAfterExec()
	{
		HiddenExecCommand(30);
		return HiddenThenPure(5);
	}

	/**
	 * Observe the default StoredValue of 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default StoredValue
	 */
	UFUNCTION()
	int DefaultZero()
	{
		return ReadStoredValue();
	}

	/**
	 * Observe PureThenHidden(0) at the default StoredValue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Inputs PureThenHidden(0)
	 * @Return 3
	 * @Boundary default plus zero
	 */
	UFUNCTION()
	int PureAtDefaultZero()
	{
		return PureThenHidden(0);
	}

	/**
	 * Observe that writing this instance leaves another at 0.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Specifier
	 * @Param Other Second actor that must stay at 0
	 * @Inputs CallableThenHidden(10) on this compared against Other
	 * @Return true when this is 11 and Other stays 0
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool CallableOrderIsIndependentAcrossInstances(ACoverageUFunctionCallableOrderActor Other)
	{
		CallableThenHidden(10);
		if (ReadStoredValue() != 11)
		{
			return false;
		}
		return Other.ReadStoredValue() == 0;
	}
}
/** @end */
