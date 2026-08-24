// Theme: Containers.TObjectPtr. WorldStory: TSet<AActor> add-dedup, Contains, Remove.
// C++ VerifyByPath: AddDedupWorked, ContainsWorked, RemoveWorked true.
// Extra: ActorSet default empty until BeginPlay. FixtureIsolated.

UCLASS()
class ACoverageHandleSetActor : AActor
{
	UPROPERTY()
	TSet<AActor> ActorSet;

	UPROPERTY()
	bool AddDedupWorked = false;

	UPROPERTY()
	bool ContainsWorked = false;

	UPROPERTY()
	bool RemoveWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor OtherActor = SpawnActor(AActor::StaticClass());

		ActorSet.Add(this);
		ActorSet.Add(this);
		ActorSet.Add(OtherActor);

		AddDedupWorked = ActorSet.Num() == 2;
		ContainsWorked = ActorSet.Contains(this) && ActorSet.Contains(OtherActor);

		ActorSet.Remove(this);
		RemoveWorked = !ActorSet.Contains(this) && ActorSet.Num() == 1;
	}
}
