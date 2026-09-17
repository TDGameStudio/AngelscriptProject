/**
 * @version v1
 * @summary HotReload VersionPair Before. Primitive delegate Execute(5) -> 15.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. Primitive delegate Execute(5) -> 15.
 * @topic Baseline
 */
// Retained after reload: FHotReloadPrimitiveSignal name, UHotReloadPrimitiveReceiver, HandlePrimitive, RunPrimitive.
// Replaced in After: extra bool/float/FString/FName parameters.
// Oracle: RunPrimitive -> 15. Extra vectors live in After (false/empty/non-Ready). FixtureIsolated.

/** Delegate FHotReloadPrimitiveSignal: carries (int Value) for this reload scenario. */
delegate int FHotReloadPrimitiveSignal(int Value);

UCLASS()
class UHotReloadPrimitiveReceiver : UObject
{
	/** Handles the primitive callback. */
	UFUNCTION()
	int HandlePrimitive(int Value)
	{
		int Result = Value + 10;
		Log(n"HotReloadDelegateTests", "Primitive V1 HandlePrimitive Value=" + Value + " Result=" + Result);
		return Result;
	}
}

/** Runs the primitive path and returns the observed result. */
int RunPrimitive(UHotReloadPrimitiveReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "Primitive V1 RunPrimitive: binding HandlePrimitive");
	FHotReloadPrimitiveSignal Signal;
	Signal.BindUFunction(Receiver, n"HandlePrimitive");
	int Result = Signal.Execute(5);
	Log(n"HotReloadDelegateTests", "Primitive V1 RunPrimitive Result=" + Result);
	return Result;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Primitive signature expansion.
 * @topic HotReload
 */
/** Delegate FHotReloadPrimitiveSignal: carries (int Value, bool bEnabled, float Scale, const FString&in Label, FName Tag) for this reload scenario. */
delegate int FHotReloadPrimitiveSignal(int Value, bool bEnabled, float Scale, const FString&in Label, FName Tag);

UCLASS()
class UHotReloadPrimitiveReceiver : UObject
{
	/** Handles the primitive callback. */
	UFUNCTION()
	int HandlePrimitive(int Value, bool bEnabled, float Scale, const FString&in Label, FName Tag)
	{
		Log(n"HotReloadDelegateTests", "Primitive V2 HandlePrimitive Value=" + Value + " bEnabled=" + bEnabled + " Scale=" + Scale + " Label=" + Label + " Tag=" + Tag);
		int Result = Value;
		if (bEnabled)
		{
			Result += int(Scale * 10.0);
		}

		Result += Label.Len();
		if (Tag == FName("Ready"))
		{
			Result += 100;
		}

		Log(n"HotReloadDelegateTests", "Primitive V2 HandlePrimitive Result=" + Result);
		return Result;
	}
}

/** Runs the primitive path and returns the observed result. */
int RunPrimitive(UHotReloadPrimitiveReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "Primitive V2 RunPrimitive: binding HandlePrimitive");
	FHotReloadPrimitiveSignal Signal;
	Signal.BindUFunction(Receiver, n"HandlePrimitive");
	int Result = Signal.Execute(7, true, 2.5f, "Alpha", FName("Ready"));
	Log(n"HotReloadDelegateTests", "Primitive V2 RunPrimitive Result=" + Result);
	return Result;
}
/** @end */
