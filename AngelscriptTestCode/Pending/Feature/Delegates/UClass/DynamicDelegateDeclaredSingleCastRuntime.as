/**
 * @version v1
 * @summary Declared single-cast delegates bind and execute. After BeginPlay, the bound flags are true, Counter is 18, ReceivedValue is 17, and ReturnResult is 36.
 * @topic Feature
 */
/**
 * @version root
 * @summary Declared single-cast delegates bind and execute. After BeginPlay, the bound flags are true, Counter is 18, ReceivedValue is 17, and ReturnResult is 36.
 * @topic Baseline
 */
/**
 * A parameterless void unicast.
 *
 * @Covers Delegates.Dynamic
 * @Inputs none
 * @Return nothing when executed
 */
delegate void FCoverageDeclaredNoParam();

/**
 * A unicast that takes one int.
 *
 * @Covers Delegates.Dynamic
 * @Inputs Value
 * @Return nothing when executed
 */
delegate void FCoverageDeclaredValue(int Value);

/**
 * A unicast that returns an int from a value.
 *
 * @Covers Delegates.Dynamic
 * @Inputs Value
 * @Return an int from the bound handler
 */
delegate int FCoverageDeclaredRetVal(int Value);

UCLASS()
class ACoverageDynamicDeclaredRuntimeActor : AActor
{
	UPROPERTY()
	FCoverageDeclaredNoParam OnNoParam;

	UPROPERTY()
	FCoverageDeclaredValue OnValue;

	UPROPERTY()
	FCoverageDeclaredRetVal OnRetVal;

	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	int ReceivedValue = 0;

	UPROPERTY()
	int ReturnResult = 0;

	UPROPERTY()
	bool bNoParamBound = false;

	UPROPERTY()
	bool bValueBound = false;

	UPROPERTY()
	bool bRetValBound = false;

	/**
	 * Binds the three unicasts and executes them.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Dynamic
	 * @Inputs none
	 * @Return nothing; Counter ends at 18 and ReturnResult is 36
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnNoParam.BindUFunction(this, n"HandleNoParam");
		OnValue.BindUFunction(this, n"HandleValue");
		OnRetVal.BindUFunction(this, n"HandleRetVal");

		bNoParamBound = OnNoParam.IsBound();
		bValueBound = OnValue.IsBound();
		bRetValBound = OnRetVal.IsBound();

		OnNoParam.Execute();
		OnValue.Execute(17);
		ReturnResult = OnRetVal.Execute(25);
	}

	/**
	 * Increments Counter.
	 *
	 * @Covers Delegates.Dynamic
	 * @Inputs none
	 * @Return nothing; Counter gains 1
	 */
	UFUNCTION()
	void HandleNoParam()
	{
		Counter += 1;
	}

	/**
	 * Stores Value and adds it to Counter.
	 *
	 * @Covers Delegates.Dynamic
	 * @Param Value the payload
	 * @Inputs Value
	 * @Return nothing; ReceivedValue is written and Counter gains Value
	 */
	UFUNCTION()
	void HandleValue(int Value)
	{
		ReceivedValue = Value;
		Counter += Value;
	}

	/**
	 * Returns Value plus 11.
	 *
	 * @Covers Delegates.Dynamic
	 * @Param Value the payload
	 * @Inputs Value
	 * @Return Value + 11
	 */
	UFUNCTION()
	int HandleRetVal(int Value)
	{
		return Value + 11;
	}

	/**
	 * Observe the default Counter.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs this
	 * @Return 0
	 * @Boundary default Counter
	 */
	UFUNCTION()
	int CounterDefaultZero()
	{
		return Counter;
	}

	/**
	 * Observe that the bound flags start false.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs this
	 * @Return true when all three bound flags are false
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool BoundFlagsDefaultFalse()
	{
		if (bNoParamBound)
		{
			return false;
		}
		if (bValueBound)
		{
			return false;
		}
		return !bRetValBound;
	}

	/**
	 * Observe the zero-value return-handler boundary.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs 0 + 11
	 * @Return 11
	 * @Boundary zero value
	 */
	UFUNCTION()
	int RetValZeroBoundary()
	{
		return 0 + 11;
	}
}
/** @end */
