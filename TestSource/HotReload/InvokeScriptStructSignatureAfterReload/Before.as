// Theme: HotReload VersionPair Before. Payload Value only, Execute -> 12.
// C++: AngelscriptHotReloadDelegateTests.cpp::InvokeScriptStructSignatureAfterReload
// Retained after reload: FHotReloadScriptPayload, FHotReloadScriptStructSignal, HandlePayload, RunPayload.
// Replaced in After: Bonus field; HandlePayload sums Value + Bonus.
// Oracle: Payload.Value 12 -> 12. Extra: default Value 0. FixtureIsolated.

USTRUCT()
struct FHotReloadScriptPayload
{
	UPROPERTY()
	int Value = 0;
}

delegate int FHotReloadScriptStructSignal(const FHotReloadScriptPayload& Payload);

UCLASS()
class UHotReloadScriptStructReceiver : UObject
{
	UFUNCTION()
	int HandlePayload(const FHotReloadScriptPayload& Payload)
	{
		Log(n"HotReloadDelegateTests", "ScriptStruct V1 HandlePayload Value=" + Payload.Value);
		return Payload.Value;
	}
}

int RunPayload(UHotReloadScriptStructReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "ScriptStruct V1 RunPayload: building payload");
	FHotReloadScriptPayload Payload;
	Payload.Value = 12;

	FHotReloadScriptStructSignal Signal;
	Signal.BindUFunction(Receiver, n"HandlePayload");
	int Result = Signal.Execute(Payload);
	Log(n"HotReloadDelegateTests", "ScriptStruct V1 RunPayload Result=" + Result);
	return Result;
}
