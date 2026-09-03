/**
 * An AS USTRUCT UFUNCTION parameter path. InitializePayload then ConsumePayload
 * returns 42 with LastValue 31 and LastBonus 11. An empty consume returns 0.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateScriptStructUFunctionParameterExecutes
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateScriptStructUFunctionParameterExecutes
 * @Provenance Theme: Feature.Delegates. Positive AS USTRUCT UFUNCTION parameter path.
 * @Provenance C++: AngelscriptCoverageDelegateTests.cpp::DelegateScriptStructUFunctionParameterExecutes
 * @Provenance Oracle: InitializePayload then ConsumePayload returns 42; LastValue==31, LastBonus==11.
 * @Provenance Extra: empty payload consume returns 0; copy independence. DefaultSafe.
 */

USTRUCT()
struct FCoverageDelegateFunctionPayload
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	int Bonus = 0;
}

UCLASS()
class UCoverageDelegateFunctionPayloadReceiver : UObject
{
	UPROPERTY()
	FCoverageDelegateFunctionPayload Payload;

	UPROPERTY()
	int LastValue = 0;

	UPROPERTY()
	int LastBonus = 0;

	/**
	 * Sets Payload to 31 / 11.
	 *
	 * @Covers Delegates.UStruct
	 * @Inputs none
	 * @Return nothing; Payload.Value is 31 and Payload.Bonus is 11
	 */
	UFUNCTION()
	void InitializePayload()
	{
		Payload.Value = 31;
		Payload.Bonus = 11;
	}

	/**
	 * Records InputPayload and returns Value plus Bonus.
	 *
	 * @Covers Delegates.UStruct
	 * @Param InputPayload the struct to consume
	 * @Inputs InputPayload.Value and InputPayload.Bonus
	 * @Return Value + Bonus
	 */
	UFUNCTION()
	int ConsumePayload(FCoverageDelegateFunctionPayload InputPayload)
	{
		LastValue = InputPayload.Value;
		LastBonus = InputPayload.Bonus;
		return InputPayload.Value + InputPayload.Bonus;
	}

	/**
	 * Observe that a default-constructed receiver handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs a local UCoverageDelegateFunctionPayloadReceiver
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		UCoverageDelegateFunctionPayloadReceiver Receiver;
		return Receiver == nullptr;
	}

	/**
	 * Observe InitializePayload then ConsumePayload.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs InitializePayload() then ConsumePayload(Payload)
	 * @Return 42
	 */
	UFUNCTION()
	int ConsumeAfterInitialize()
	{
		InitializePayload();
		return ConsumePayload(Payload);
	}

	/**
	 * Observe that consuming an empty payload returns 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs a default FCoverageDelegateFunctionPayload
	 * @Return 0
	 * @Boundary empty consume
	 */
	UFUNCTION()
	int EmptyConsume()
	{
		FCoverageDelegateFunctionPayload Empty;
		return ConsumePayload(Empty);
	}

	/**
	 * Observe that copying a payload and clearing the copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs Original 31/11; Copy cleared
	 * @Return true when Original stays 31/11 and Copy is 0/0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool PayloadCopyIndependence()
	{
		FCoverageDelegateFunctionPayload Original;
		Original.Value = 31;
		Original.Bonus = 11;
		FCoverageDelegateFunctionPayload Copy = Original;
		Copy.Value = 0;
		Copy.Bonus = 0;
		if (Original.Value != 31)
		{
			return false;
		}
		if (Original.Bonus != 11)
		{
			return false;
		}
		if (Copy.Value != 0)
		{
			return false;
		}
		return Copy.Bonus == 0;
	}
}
