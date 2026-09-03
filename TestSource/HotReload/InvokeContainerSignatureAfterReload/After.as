// Theme: HotReload VersionPair After. Container parameter expansion.
// C++: AngelscriptHotReloadDelegateTests.cpp::InvokeContainerSignatureAfterReload
// Retained: Values array path, receiver, RunContainers, BindUFunction HandleContainers.
// Replaced: TArray<FVector> Vectors, TMap<FString,int> Scores, TSet<FName> Tags.
// Oracle: Execute -> 147. Extra: Tags.Contains Missing is 0; empty map Find leaves 0. FixtureIsolated.

/** Delegate FHotReloadContainerSignal: carries (TArray<int> Values, TArray<FVector> Vectors, TMap<FString, int> Scores, TSet<FName> Tags) for this reload scenario. */
delegate int FHotReloadContainerSignal(TArray<int> Values, TArray<FVector> Vectors, TMap<FString, int> Scores, TSet<FName> Tags);

UCLASS()
class UHotReloadContainerReceiver : UObject
{
	/** Handles the containers callback. */
	UFUNCTION()
	int HandleContainers(TArray<int> Values, TArray<FVector> Vectors, TMap<FString, int> Scores, TSet<FName> Tags)
	{
		Log(n"HotReloadDelegateTests", "Container V2 HandleContainers Values.Num=" + Values.Num() + " Vectors.Num=" + Vectors.Num() + " Scores.Num=" + Scores.Num() + " Tags.Num=" + Tags.Num());
		int AlphaScore = 0;
		Scores.Find("Alpha", AlphaScore);

		int BetaScore = 0;
		Scores.Find("Beta", BetaScore);

		int Result = Values.Num() + Values[0] + Values[1];
		Result += int(Vectors[0].X + Vectors[1].Y);
		Result += AlphaScore + BetaScore;
		Result += Tags.Contains(FName("Ready")) ? 100 : 0;
		Result += Tags.Contains(FName("Missing")) ? 1000 : 0;
		Log(n"HotReloadDelegateTests", "Container V2 HandleContainers AlphaScore=" + AlphaScore + " BetaScore=" + BetaScore + " HasReady=" + Tags.Contains(FName("Ready")) + " HasMissing=" + Tags.Contains(FName("Missing")) + " Result=" + Result);
		return Result;
	}
}

/** Runs the containers path and returns the observed result. */
int RunContainers(UHotReloadContainerReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "Container V2 RunContainers: building containers");
	TArray<int> Values;
	Values.Add(5);
	Values.Add(6);

	TArray<FVector> Vectors;
	Vectors.Add(FVector(7.0, 0.0, 0.0));
	Vectors.Add(FVector(0.0, 8.0, 0.0));

	TMap<FString, int> Scores;
	Scores.Add("Alpha", 9);
	Scores.Add("Beta", 10);

	TSet<FName> Tags;
	Tags.Add(FName("Ready"));
	Tags.Add(FName("Live"));

	FHotReloadContainerSignal Signal;
	Signal.BindUFunction(Receiver, n"HandleContainers");
	int Result = Signal.Execute(Values, Vectors, Scores, Tags);
	Log(n"HotReloadDelegateTests", "Container V2 RunContainers Result=" + Result);
	return Result;
}
