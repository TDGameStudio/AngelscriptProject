/**
 * @version v1
 * @summary A UPROPERTY TArray of AActor holds this plus two spawned children and FindIndex(this) is 0.
 * @topic Containers
 *
 * UObjectReferences
 */
/**
 * @begin UObjectReferences
 * @summary A UPROPERTY TArray of AActor holds this plus two spawned children and FindIndex(this) is 0.
 * @topic Containers
 */
UCLASS()
class ATArrayUObjectReferencesActor : AActor
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
/** @end */
