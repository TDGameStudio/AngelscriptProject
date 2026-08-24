// Theme: Containers.TMap. WorldStory: FindOrAdd existing vs missing key.
// C++ VerifyByPath: InitialSize=1, FinalSize=2, Key10Value=150, Key20Value=200.
// Extra: Key* default 0 until BeginPlay. FixtureIsolated.

UCLASS()
class ACoverageTMapFindOrAddActor : AActor
{
	UPROPERTY()
	TMap<int, int> CounterMap;

	UPROPERTY()
	int InitialSize = 0;

	UPROPERTY()
	int FinalSize = 0;

	UPROPERTY()
	int Key10Value = 0;

	UPROPERTY()
	int Key20Value = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Pre-populate with one entry
		CounterMap.Add(10, 100);
		InitialSize = CounterMap.Num();

		// FindOrAdd on existing key - should return reference to existing value
		CounterMap.FindOrAdd(10) += 50;

		// FindOrAdd on non-existent key - should add default (0) and return reference
		CounterMap.FindOrAdd(20) += 200;

		FinalSize = CounterMap.Num();
		Key10Value = CounterMap[10];
		Key20Value = CounterMap[20];
	}
}
