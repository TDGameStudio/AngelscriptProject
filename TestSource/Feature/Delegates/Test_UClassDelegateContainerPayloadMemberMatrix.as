// Theme: Feature.Delegates. WorldStory: TArray/TMap/TSet payloads through delegates.
// C++: AngelscriptCoverageUClassPropertyTests.cpp::UClassDelegateContainerPayloadMemberMatrix
// Spawn + BeginPlay oracle: ComputeValueCount/VectorCount/ScoreCount/TagCount 2,
// bComputeHasReadyTag true, ComputeResult 129 (5+6+1+2+7+8+100), SignalValueCount 2,
// SignalScoreCount 2, SignalScoreValue 17, SignalTotal 28 (5+6+17).
// Extra: empty containers Num 0; empty compute path without Ready tag. Keep ComputeResult.
// FixtureIsolated.

delegate int FUClassPropertyContainerComputeDelegate(TArray<int> Values, TArray<FVector> Vectors, TMap<FString, int> Scores, TSet<FName> Tags);
event void FUClassPropertyContainerEvent(TArray<int> Values, TMap<FName, int> Scores);

UCLASS()
class ACoverageUClassDelegateContainerPayloadActor : AActor
{
	UPROPERTY()
	FUClassPropertyContainerComputeDelegate OnContainerCompute;

	UPROPERTY()
	FUClassPropertyContainerEvent OnContainerSignal;

	UPROPERTY()
	bool bContainerComputeBound = false;

	UPROPERTY()
	bool bContainerSignalBound = false;

	UPROPERTY()
	int ComputeValueCount = 0;

	UPROPERTY()
	int ComputeVectorCount = 0;

	UPROPERTY()
	int ComputeScoreCount = 0;

	UPROPERTY()
	int ComputeTagCount = 0;

	UPROPERTY()
	bool bComputeHasReadyTag = false;

	UPROPERTY()
	int ComputeResult = 0;

	UPROPERTY()
	int SignalValueCount = 0;

	UPROPERTY()
	int SignalScoreCount = 0;

	UPROPERTY()
	int SignalScoreValue = 0;

	UPROPERTY()
	int SignalTotal = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Values;
		Values.Add(5);
		Values.Add(6);

		TArray<FVector> Vectors;
		Vectors.Add(FVector(1, 0, 0));
		Vectors.Add(FVector(0, 2, 0));

		TMap<FString, int> Scores;
		Scores.Add("Alpha", 7);
		Scores.Add("Beta", 8);

		TSet<FName> Tags;
		Tags.Add(n"Ready");
		Tags.Add(n"Live");

		OnContainerCompute.BindUFunction(this, n"HandleContainerCompute");
		bContainerComputeBound = OnContainerCompute.IsBound();
		ComputeResult = OnContainerCompute.Execute(Values, Vectors, Scores, Tags);

		TMap<FName, int> SignalScores;
		SignalScores.Add(n"First", 13);
		SignalScores.Add(n"Second", 17);

		OnContainerSignal.AddUFunction(this, n"HandleContainerSignal");
		bContainerSignalBound = OnContainerSignal.IsBound();
		OnContainerSignal.Broadcast(Values, SignalScores);
	}

	UFUNCTION()
	int HandleContainerCompute(TArray<int> Values, TArray<FVector> Vectors, TMap<FString, int> Scores, TSet<FName> Tags)
	{
		ComputeValueCount = Values.Num();
		ComputeVectorCount = Vectors.Num();
		ComputeScoreCount = Scores.Num();
		ComputeTagCount = Tags.Num();
		bComputeHasReadyTag = Tags.Contains(n"Ready");

		int AlphaScore = 0;
		int BetaScore = 0;
		Scores.Find("Alpha", AlphaScore);
		Scores.Find("Beta", BetaScore);

		return Values[0] + Values[1] + int(Vectors[0].X) + int(Vectors[1].Y) + AlphaScore + BetaScore + (bComputeHasReadyTag ? 100 : 0);
	}

	UFUNCTION()
	void HandleContainerSignal(TArray<int> Values, TMap<FName, int> Scores)
	{
		SignalValueCount = Values.Num();
		SignalScoreCount = Scores.Num();
		Scores.Find(n"Second", SignalScoreValue);
		SignalTotal = Values[0] + Values[1] + SignalScoreValue;
	}
}

int Observe_EmptyContainers_DefaultNum()
{
	TArray<int> Values;
	TArray<FVector> Vectors;
	TMap<FString, int> Scores;
	TSet<FName> Tags;
	return Values.Num() + Vectors.Num() + Scores.Num() + Tags.Num();
}

int Observe_ComputeResult_DefaultZero(ACoverageUClassDelegateContainerPayloadActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateContainerPayloadMemberMatrix setup: required Actor is null");
	}
	return Actor.ComputeResult;
}

bool Observe_Array_CopyIndependence()
{
	TArray<int> Original;
	Original.Add(5);
	TArray<int> Copy = Original;
	Copy.Add(6);
	return Original.Num() == 1 && Copy.Num() == 2;
}

bool Observe_EmptySet_MissingReadyTag()
{
	TSet<FName> Tags;
	return !Tags.Contains(n"Ready");
}
