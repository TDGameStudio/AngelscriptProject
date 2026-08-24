// Theme: Containers.TMap. WorldStory: TMap<int, FVector> values.
// C++ GetMapNum IntToVectorMap=3; FirstVectorValue Equals (1,2,3).
// Extra: FirstVectorValue default Zero until BeginPlay. FixtureIsolated.

UCLASS()
class ACoverageTMapValueTypesActor : AActor
{
	UPROPERTY()
	TMap<int, FVector> IntToVectorMap;

	UPROPERTY()
	FVector FirstVectorValue;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// FVector values
		IntToVectorMap.Add(1, FVector(1.0, 2.0, 3.0));
		IntToVectorMap.Add(2, FVector(4.0, 5.0, 6.0));
		IntToVectorMap.Add(3, FVector(7.0, 8.0, 9.0));
		FirstVectorValue = IntToVectorMap[1];
	}
}
