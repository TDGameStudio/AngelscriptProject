// Theme: HotReload VersionPair After. Primitive signature expansion.
// C++: AngelscriptHotReloadDelegateTests.cpp::InvokePrimitiveSignatureAfterParameterExpansion
// Retained: receiver class, RunPrimitive global, BindUFunction HandlePrimitive.
// Replaced: FHotReloadPrimitiveSignal(int, bool bEnabled, float Scale, const FString&in Label, FName Tag).
// Oracle: Execute(7, true, 2.5f, "Alpha", Ready) -> 137.
// Extra: bEnabled false skips Scale*10; empty Label Len=0; Tag != Ready skips +100. FixtureIsolated.

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
