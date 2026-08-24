// Theme: Feature.Delegates. Positive: script USTRUCT value argument through Execute.
// C++: AngelscriptDelegateScriptStructArgumentTests.cpp::ExecutesDelegateWithScriptStructValueArgument
// ExpectGlobalReturn oracle: RunScriptStructDelegate()==42 (19+23).
// Extra: default payload 0; copy independence of Value/Bonus. Keep RunScriptStructDelegate.
// DefaultSafe.

USTRUCT()
struct FDelegateScriptStructPayload
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	int Bonus = 0;
}

delegate int FDelegateScriptStructSignal(FDelegateScriptStructPayload Payload);

UCLASS()
class UDelegateScriptStructReceiver : UObject
{
	UFUNCTION()
	int HandlePayload(FDelegateScriptStructPayload Payload)
	{
		return Payload.Value + Payload.Bonus;
	}
}

int RunScriptStructDelegate()
{
	FDelegateScriptStructPayload Payload;
	Payload.Value = 19;
	Payload.Bonus = 23;

	UDelegateScriptStructReceiver Receiver = UDelegateScriptStructReceiver();
	FDelegateScriptStructSignal Signal;
	Signal.BindUFunction(Receiver, n"HandlePayload");
	return Signal.Execute(Payload);
}

int Observe_RunScriptStructDelegate()
{
	return RunScriptStructDelegate();
}

int Observe_Payload_DefaultZero()
{
	FDelegateScriptStructPayload Payload;
	return Payload.Value + Payload.Bonus;
}

bool Observe_Payload_CopyIndependence()
{
	FDelegateScriptStructPayload Original;
	Original.Value = 19;
	Original.Bonus = 23;
	FDelegateScriptStructPayload Copy = Original;
	Copy.Value = 0;
	Copy.Bonus = 0;
	return Original.Value == 19 && Original.Bonus == 23 && Copy.Value == 0 && Copy.Bonus == 0;
}

bool Observe_Receiver_NullBoundary()
{
	UDelegateScriptStructReceiver Receiver = nullptr;
	return Receiver == nullptr;
}
