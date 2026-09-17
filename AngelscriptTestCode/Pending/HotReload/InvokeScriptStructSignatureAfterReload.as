/**
 * @version v1
 * @summary HotReload VersionPair Before. Payload Value only, Execute -> 12.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Payload Value only, Execute -> 12.
 * @topic Baseline
 */
// Retained after reload: FHotReloadScriptPayload, FHotReloadScriptStructSignal, HandlePayload, RunPayload.
// Replaced in After: Bonus field; HandlePayload sums Value + Bonus.
// Oracle: Payload.Value 12 -> 12. Extra: default Value 0. FixtureIsolated.

USTRUCT()
struct FHotReloadScriptPayload
{
	UPROPERTY()
	int Value = 0;
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
		Log(n"HotReloadDelegateTests", "ScriptStruct V1 HandlePayload Value=" + Payload.Value);
		return Payload.Value;
	}
}

/** Runs the payload path and returns the observed result. */
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
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Payload gains Bonus; struct object replaced.
 * @topic HotReload
 */
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
/** @end */
