// Theme: HotReload VersionPair After. Payload gains Bonus; struct object replaced.
// C++: AngelscriptHotReloadDelegateTests.cpp::InvokeScriptStructSignatureAfterReload
// Retained: FHotReloadScriptPayload, FHotReloadScriptStructSignal, HandlePayload, RunPayload, Value field.
// Replaced: Bonus field; HandlePayload Value + Bonus; Value=20 Bonus=22.
// Oracle: RunPayload -> 42. Extra: default Bonus 0. FixtureIsolated.

USTRUCT()
struct FHotReloadScriptPayload
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	int Bonus = 0;
}

/** Delegate FHotReloadScriptStructSignal: carries (const FHotReloadScriptPayload&in Payload) for this reload scenario. */
delegate int FHotReloadScriptStructSignal(const FHotReloadScriptPayload&in Payload);

UCLASS()
class UHotReloadScriptStructReceiver : UObject
{
	/** Handles the payload callback. */
	UFUNCTION()
	int HandlePayload(const FHotReloadScriptPayload&in Payload)
	{
		int Result = Payload.Value + Payload.Bonus;
		Log(n"HotReloadDelegateTests", "ScriptStruct V2 HandlePayload Value=" + Payload.Value + " Bonus=" + Payload.Bonus + " Result=" + Result);
		return Result;
	}
}

/** Runs the payload path and returns the observed result. */
int RunPayload(UHotReloadScriptStructReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "ScriptStruct V2 RunPayload: building payload");
	FHotReloadScriptPayload Payload;
	Payload.Value = 20;
	Payload.Bonus = 22;

	FHotReloadScriptStructSignal Signal;
	Signal.BindUFunction(Receiver, n"HandlePayload");
	int Result = Signal.Execute(Payload);
	Log(n"HotReloadDelegateTests", "ScriptStruct V2 RunPayload Result=" + Result);
	return Result;
}
