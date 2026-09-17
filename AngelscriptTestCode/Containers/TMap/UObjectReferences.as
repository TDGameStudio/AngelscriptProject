/**
 * @version v1
 * @summary Live Actor handles on a TMap UPROPERTY stay addressable by key.
 * @topic Containers
 *
 * UObjectReferences
 */
/**
 * @begin UObjectReferences
 * @summary Live Actor handles on a TMap UPROPERTY stay addressable by key.
 * @topic Containers
 */
UCLASS()
class ATMapUObjectReferencesActor : AActor
{
	UPROPERTY()
	TMap<int, AActor> ActorReferences;

	UPROPERTY()
	int ActorCount;

	UPROPERTY()
	bool bContainsSelf;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ActorReferences.Add(0, this);
		AActor Child1 = SpawnActor(AActor::StaticClass(), FVector::ZeroVector);
		AActor Child2 = SpawnActor(AActor::StaticClass(), FVector(100, 0, 0));
		ActorReferences.Add(1, Child1);
		ActorReferences.Add(2, Child2);
		ActorCount = ActorReferences.Num();
		bContainsSelf = ActorReferences.Contains(0);
		if (ActorReferences[0] != this)
		{
			ActorCount = -1;
		}
	}
}
/** @end */
