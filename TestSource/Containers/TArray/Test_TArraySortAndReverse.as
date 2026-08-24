// Theme: Containers.TArray. WorldStory: Sort 5,2,8,1,9 -> 1,2,5,8,9.
// C++ VerifyByPath IntArray[0..4]. Extra: EmptyNumBefore is 0. FixtureIsolated.

UCLASS()
class ACoverageTArraySortActor : AActor
{
	UPROPERTY()
	TArray<int> IntArray;

	UPROPERTY()
	int EmptyNumBefore = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		EmptyNumBefore = IntArray.Num();
		IntArray.Add(5);
		IntArray.Add(2);
		IntArray.Add(8);
		IntArray.Add(1);
		IntArray.Add(9);
		IntArray.Sort();
	}
}
