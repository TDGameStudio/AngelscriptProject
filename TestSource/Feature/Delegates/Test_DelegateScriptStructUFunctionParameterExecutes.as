// Theme: Feature.Delegates. Positive AS USTRUCT UFUNCTION parameter path.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateScriptStructUFunctionParameterExecutes
// Oracle: InitializePayload then ConsumePayload returns 42; LastValue==31, LastBonus==11.
// Extra: empty payload consume returns 0; copy independence. DefaultSafe.

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

	UFUNCTION()
	void InitializePayload()
	{
		Payload.Value = 31;
		Payload.Bonus = 11;
	}

	UFUNCTION()
	int ConsumePayload(FCoverageDelegateFunctionPayload InputPayload)
	{
		LastValue = InputPayload.Value;
		LastBonus = InputPayload.Bonus;
		return InputPayload.Value + InputPayload.Bonus;
	}
}

bool Observe_FunctionPayload_EmptyDefaultIsNull()
{
	UCoverageDelegateFunctionPayloadReceiver Receiver;
	return Receiver == nullptr;
}

int Observe_FunctionPayload_ConsumeAfterInitialize(UCoverageDelegateFunctionPayloadReceiver Receiver)
{
	if (Receiver == nullptr)
	{
		throw("TS-FEAT-0028 setup: required UCoverageDelegateFunctionPayloadReceiver is null");
	}
	Receiver.InitializePayload();
	return Receiver.ConsumePayload(Receiver.Payload);
}

int Observe_FunctionPayload_EmptyConsume(UCoverageDelegateFunctionPayloadReceiver Receiver)
{
	if (Receiver == nullptr)
	{
		throw("TS-FEAT-0028 setup: required UCoverageDelegateFunctionPayloadReceiver is null");
	}
	FCoverageDelegateFunctionPayload Empty;
	return Receiver.ConsumePayload(Empty);
}

bool Observe_FunctionPayload_CopyIndependence()
{
	FCoverageDelegateFunctionPayload Original;
	Original.Value = 31;
	Original.Bonus = 11;
	FCoverageDelegateFunctionPayload Copy = Original;
	Copy.Value = 0;
	Copy.Bonus = 0;
	return Original.Value == 31 && Original.Bonus == 11 && Copy.Value == 0 && Copy.Bonus == 0;
}
