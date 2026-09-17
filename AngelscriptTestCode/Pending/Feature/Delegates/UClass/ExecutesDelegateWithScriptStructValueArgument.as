/**
 * @version v1
 * @summary A script USTRUCT value argument through Execute. RunScriptStructDelegate returns 42 (19+23). An empty payload sums to 0.
 * @topic Feature
 */
/**
 * @version root
 * @summary A script USTRUCT value argument through Execute. RunScriptStructDelegate returns 42 (19+23). An empty payload sums to 0.
 * @topic Baseline
 */
USTRUCT()
struct FDelegateScriptStructPayload
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	int Bonus = 0;
}

/**
 * A unicast that takes a script struct payload by value.
 *
 * @Covers Delegates.Execute
 * @Inputs Payload
 * @Return an int from the bound handler
 */
delegate int FDelegateScriptStructSignal(FDelegateScriptStructPayload Payload);

UCLASS()
class UDelegateScriptStructReceiver : UObject
{
	/**
	 * Returns Value plus Bonus.
	 *
	 * @Covers Delegates.Execute
	 * @Param Payload the struct payload
	 * @Inputs Payload.Value and Payload.Bonus
	 * @Return Value + Bonus
	 */
	UFUNCTION()
	int HandlePayload(FDelegateScriptStructPayload Payload)
	{
		return Payload.Value + Payload.Bonus;
	}

	/**
	 * Binds HandlePayload and executes a 19/23 payload.
	 *
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int RunScriptStructDelegate()
	{
		FDelegateScriptStructPayload Payload;
		Payload.Value = 19;
		Payload.Bonus = 23;

		FDelegateScriptStructSignal Signal;
		Signal.BindUFunction(this, n"HandlePayload");
		return Signal.Execute(Payload);
	}

	/**
	 * Observe that an empty payload sums to 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a default FDelegateScriptStructPayload
	 * @Return 0
	 * @Boundary default payload
	 */
	UFUNCTION()
	int PayloadDefaultZero()
	{
		FDelegateScriptStructPayload Payload;
		return Payload.Value + Payload.Bonus;
	}

	/**
	 * Observe that copying a payload and clearing the copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Original 19/23; Copy cleared
	 * @Return true when Original stays 19/23 and Copy is 0/0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool PayloadCopyIndependence()
	{
		FDelegateScriptStructPayload Original;
		Original.Value = 19;
		Original.Bonus = 23;
		FDelegateScriptStructPayload Copy = Original;
		Copy.Value = 0;
		Copy.Bonus = 0;
		if (Original.Value != 19)
		{
			return false;
		}
		if (Original.Bonus != 23)
		{
			return false;
		}
		if (Copy.Value != 0)
		{
			return false;
		}
		return Copy.Bonus == 0;
	}

	/**
	 * Observe that a null receiver handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a nullptr UDelegateScriptStructReceiver
	 * @Return true when the handle is null
	 * @Boundary null receiver
	 */
	UFUNCTION()
	bool ReceiverNullBoundary()
	{
		UDelegateScriptStructReceiver Receiver = nullptr;
		return Receiver == nullptr;
	}
}
/** @end */
