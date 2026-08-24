// Theme: Containers.TArray. WorldStory: insert/remove sequence ends [10,20,30,35].
// Extra: values start empty. FixtureIsolated.

UCLASS()
class ACoverageTArrayInsertActor : AActor
{
	UPROPERTY()
	TArray<int> Values;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Values.Add(10);
		Values.Add(20);
		Values.Add(30);
		Values.Insert(15, 1);
		Values.Insert(5, 0);
		Values.Insert(35, 5);
		Values.RemoveAt(2);
		Values.RemoveAt(0);
	}
}
