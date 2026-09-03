// Theme: HotReload VersionPair Before. TArray<int> Values only.
// C++: AngelscriptHotReloadDelegateTests.cpp::InvokeContainerSignatureAfterReload
// Retained after reload: FHotReloadContainerSignal name, UHotReloadContainerReceiver, HandleContainers, RunContainers.
// Replaced in After: Vectors, Scores, Tags parameters.
// Oracle: Values {3,4} -> 9. Extra: empty array is not the C++ Execute path. FixtureIsolated.

/** Delegate FHotReloadContainerSignal: carries (TArray<int> Values) for this reload scenario. */
delegate int FHotReloadContainerSignal(TArray<int> Values);

UCLASS()
class UHotReloadContainerReceiver : UObject
{
	/** Handles the containers callback. */
	UFUNCTION()
	int HandleContainers(TArray<int> Values)
	{
		int Result = Values.Num() + Values[0] + Values[1];
		Log(n"HotReloadDelegateTests", "Container V1 HandleContainers Values.Num=" + Values.Num() + " First=" + Values[0] + " Second=" + Values[1] + " Result=" + Result);
		return Result;
	}
}

/** Runs the containers path and returns the observed result. */
int RunContainers(UHotReloadContainerReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "Container V1 RunContainers: building Values");
	TArray<int> Values;
	Values.Add(3);
	Values.Add(4);

	FHotReloadContainerSignal Signal;
	Signal.BindUFunction(Receiver, n"HandleContainers");
	int Result = Signal.Execute(Values);
	Log(n"HotReloadDelegateTests", "Container V1 RunContainers Result=" + Result);
	return Result;
}
