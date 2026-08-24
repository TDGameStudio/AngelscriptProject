// Theme: HotReload VersionPair Before. Primitive delegate Execute(5) -> 15.
// C++: AngelscriptHotReloadDelegateTests.cpp::InvokePrimitiveSignatureAfterParameterExpansion
// Retained after reload: FHotReloadPrimitiveSignal name, UHotReloadPrimitiveReceiver, HandlePrimitive, RunPrimitive.
// Replaced in After: extra bool/float/FString/FName parameters.
// Oracle: RunPrimitive -> 15. Extra vectors live in After (false/empty/non-Ready). FixtureIsolated.

delegate int FHotReloadPrimitiveSignal(int Value);

UCLASS()
class UHotReloadPrimitiveReceiver : UObject
{
	UFUNCTION()
	int HandlePrimitive(int Value)
	{
		int Result = Value + 10;
		Log(n"HotReloadDelegateTests", "Primitive V1 HandlePrimitive Value=" + Value + " Result=" + Result);
		return Result;
	}
}

int RunPrimitive(UHotReloadPrimitiveReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "Primitive V1 RunPrimitive: binding HandlePrimitive");
	FHotReloadPrimitiveSignal Signal;
	Signal.BindUFunction(Receiver, n"HandlePrimitive");
	int Result = Signal.Execute(5);
	Log(n"HotReloadDelegateTests", "Primitive V1 RunPrimitive Result=" + Result);
	return Result;
}
