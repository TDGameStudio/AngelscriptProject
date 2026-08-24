// Theme: Containers.TArray. WorldStory: Reserve(100) then 10 adds; FinalSize 10;
// ReservedArray[0]=0 [5]=50 [9]=90. Extra: empty before loop. FixtureIsolated.

UCLASS()
class ACoverageTArrayReserveActor : AActor
{
	UPROPERTY()
	TArray<int> ReservedArray;

	UPROPERTY()
	int FinalSize;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ReservedArray.Reserve(100);
		for (int i = 0; i < 10; i++)
		{
			ReservedArray.Add(i * 10);
		}
		FinalSize = ReservedArray.Num();
	}
}
