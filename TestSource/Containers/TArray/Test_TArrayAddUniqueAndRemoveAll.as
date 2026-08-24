// Theme: Containers.TArray. WorldStory: AddUnique -> 3; Remove(2) count and FinalSize.
// Extra: duplicate AddUnique does not grow. FixtureIsolated.

UCLASS()
class ACoverageTArrayUniqueRemoveActor : AActor
{
	UPROPERTY()
	int UniqueArraySize;

	UPROPERTY()
	int RemovedCount;

	UPROPERTY()
	int FinalSize;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TArray<int> Numbers;
		Numbers.AddUnique(5);
		Numbers.AddUnique(10);
		Numbers.AddUnique(5);
		Numbers.AddUnique(15);
		Numbers.AddUnique(10);
		UniqueArraySize = Numbers.Num();

		TArray<int> Values;
		Values.Add(1);
		Values.Add(2);
		Values.Add(3);
		Values.Add(2);
		Values.Add(4);
		Values.Add(2);
		Values.Add(5);
		int Removed = Values.Remove(2);
		RemovedCount = Removed;
		FinalSize = Values.Num();
	}
}
