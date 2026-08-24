// Theme: Containers.TMap. WorldStory: TMap<int, FCoverageTMapPayload> user USTRUCT values.
// C++ VerifyByPath: PayloadCount=2, bFoundPayload true, FoundPayload Score/Label/bComplete
// 22/"Second"/true, OverwrittenPayload 33/"Replacement"/true. Extra: PayloadCount 0 until BeginPlay.
// FixtureIsolated.

USTRUCT()
struct FCoverageTMapPayload
{
	UPROPERTY()
	int Score = 0;

	UPROPERTY()
	FString Label;

	UPROPERTY()
	bool bComplete = false;
}

UCLASS()
class ACoverageTMapUserStructValuesActor : AActor
{
	UPROPERTY()
	TMap<int, FCoverageTMapPayload> StructValues;

	UPROPERTY()
	FCoverageTMapPayload FoundPayload;

	UPROPERTY()
	FCoverageTMapPayload OverwrittenPayload;

	UPROPERTY()
	bool bFoundPayload = false;

	UPROPERTY()
	int PayloadCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FCoverageTMapPayload First;
		First.Score = 11;
		First.Label = "First";
		First.bComplete = false;

		FCoverageTMapPayload Second;
		Second.Score = 22;
		Second.Label = "Second";
		Second.bComplete = true;

		FCoverageTMapPayload Replacement;
		Replacement.Score = 33;
		Replacement.Label = "Replacement";
		Replacement.bComplete = true;

		StructValues.Add(1, First);
		StructValues.Add(2, Second);
		bFoundPayload = StructValues.Find(2, FoundPayload);

		StructValues.Add(1, Replacement);
		OverwrittenPayload = StructValues[1];
		PayloadCount = StructValues.Num();
	}
}
