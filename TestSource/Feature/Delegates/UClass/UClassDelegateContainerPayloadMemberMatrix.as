/**
 * TArray/TMap/TSet payloads through delegates. After BeginPlay,
 * ComputeValueCount/VectorCount/ScoreCount/TagCount 2, bComputeHasReadyTag true,
 * ComputeResult 129 (5+6+1+2+7+8+100), SignalValueCount 2, SignalScoreCount 2,
 * SignalScoreValue 17, SignalTotal 28 (5+6+17). Empty containers Num 0.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.UClassDelegateContainerPayloadMemberMatrix
 * @Harness UClass
 * @Tag Feature.Delegates.UClassDelegateContainerPayloadMemberMatrix
 * @Provenance Theme: Feature.Delegates. WorldStory: TArray/TMap/TSet payloads through delegates.
 * @Provenance C++: AngelscriptCoverageUClassPropertyTests.cpp::UClassDelegateContainerPayloadMemberMatrix
 * @Provenance Spawn + BeginPlay oracle: ComputeValueCount/VectorCount/ScoreCount/TagCount 2,
 * @Provenance bComputeHasReadyTag true, ComputeResult 129 (5+6+1+2+7+8+100), SignalValueCount 2,
 * @Provenance SignalScoreCount 2, SignalScoreValue 17, SignalTotal 28 (5+6+17).
 * @Provenance Extra: empty containers Num 0; empty compute path without Ready tag. Keep ComputeResult.
 * @Provenance FixtureIsolated.
 */

/**
 * A unicast of array/map/set payloads that returns int.
 *
 * @Covers Delegates.Execute
 * @Inputs Values, Vectors, Scores, and Tags
 * @Return int
 */
delegate int FUClassPropertyContainerComputeDelegate(TArray<int> Values, TArray<FVector> Vectors, TMap<FString, int> Scores, TSet<FName> Tags);

/**
 * A multicast of array and map payloads.
 *
 * @Covers Delegates.Broadcast
 * @Inputs Values and Scores
 * @Return void
 */
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

	/**
	 * WorldStory: BeginPlay binds and executes/broadcasts container payloads.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return ComputeResult 129, SignalTotal 28
	 */
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

	/**
	 * Score array/map/set payloads and record Ready.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Values Integers received by value
	 * @Param Vectors Vectors received by value
	 * @Param Scores String-to-int map received by value
	 * @Param Tags Names received by value
	 * @Inputs Values, Vectors, Scores, and Tags
	 * @Return Values[0]+Values[1]+Vectors[0].X+Vectors[1].Y+Alpha+Beta+100 if Ready
	 */
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

	/**
	 * Score array and map payloads into SignalTotal.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Values Integers received by value
	 * @Param Scores Name-to-int map received by value
	 * @Inputs Values and Scores
	 * @Return void
	 */
	UFUNCTION()
	void HandleContainerSignal(TArray<int> Values, TMap<FName, int> Scores)
	{
		SignalValueCount = Values.Num();
		SignalScoreCount = Scores.Num();
		Scores.Find(n"Second", SignalScoreValue);
		SignalTotal = Values[0] + Values[1] + SignalScoreValue;
	}

	/**
	 * Observe empty container Num sums.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs empty array, map, and set
	 * @Return 0
	 * @Boundary empty containers
	 */
	UFUNCTION()
	int EmptyContainersDefaultNum()
	{
		TArray<int> Values;
		TArray<FVector> Vectors;
		TMap<FString, int> Scores;
		TSet<FName> Tags;
		return Values.Num() + Vectors.Num() + Scores.Num() + Tags.Num();
	}

	/**
	 * Observe the default ComputeResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default ComputeResult
	 */
	UFUNCTION()
	int ComputeResultDefaultZero()
	{
		return ComputeResult;
	}

	/**
	 * Observe that mutating an array copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Original [5] and a copy that adds 6
	 * @Return true when Original.Num is 1 and Copy.Num is 2
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ArrayCopyIndependence()
	{
		TArray<int> Original;
		Original.Add(5);
		TArray<int> Copy = Original;
		Copy.Add(6);
		if (Original.Num() != 1)
		{
			return false;
		}
		return Copy.Num() == 2;
	}

	/**
	 * Observe that an empty set does not contain Ready.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs empty Tags
	 * @Return true when Ready is missing
	 * @Boundary missing Ready tag
	 */
	UFUNCTION()
	bool EmptySetMissingReadyTag()
	{
		TSet<FName> Tags;
		return !Tags.Contains(n"Ready");
	}
}
