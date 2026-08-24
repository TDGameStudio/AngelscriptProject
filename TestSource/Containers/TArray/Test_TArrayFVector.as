// Theme: Containers.TArray. WorldStory: insert then remove last; length 3.
// Extra: starts empty. FixtureIsolated.

UCLASS()
class ACoverageTArrayVectorActor : AActor
{
	UPROPERTY()
	TArray<FVector> VectorArray;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		VectorArray.Add(FVector(1, 0, 0));
		VectorArray.Add(FVector(0, 1, 0));
		VectorArray.Add(FVector(0, 0, 1));
		VectorArray.Insert(FVector(0.5, 0.5, 0), 1);
		VectorArray.RemoveAt(VectorArray.Num() - 1);
	}
}
