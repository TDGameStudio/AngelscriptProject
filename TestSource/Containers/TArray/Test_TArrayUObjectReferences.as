// Theme: Containers.TArray. WorldStory: self plus two spawned children; ActorCount 3;
// Contains self. Extra: FindIndex(this)==0. FixtureIsolated.

UCLASS()
class ACoverageTArrayActorRefsActor : AActor
{
	UPROPERTY()
	TArray<AActor> ActorReferences;

	UPROPERTY()
	int ActorCount;

	UPROPERTY()
	bool bContainsSelf;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ActorReferences.Add(this);
		AActor Child1 = SpawnActor(AActor::StaticClass(), FVector::ZeroVector);
		AActor Child2 = SpawnActor(AActor::StaticClass(), FVector(100, 0, 0));
		ActorReferences.Add(Child1);
		ActorReferences.Add(Child2);
		ActorCount = ActorReferences.Num();
		bContainsSelf = ActorReferences.Contains(this);
		int SelfIndex = ActorReferences.FindIndex(this);
		if (SelfIndex != 0)
		{
			ActorCount = -1;
		}
	}
}
