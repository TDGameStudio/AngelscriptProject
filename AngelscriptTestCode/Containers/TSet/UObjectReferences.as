/**
 * @version v1
 * @summary Live Actor handles on a TSet UPROPERTY include self and spawned children.
 * @topic Containers
 *
 * UObjectReferences
 */
/**
 * @begin UObjectReferences
 * @summary Live Actor handles on a TSet UPROPERTY include self and spawned children.
 * @topic Containers
 */
UCLASS()
class ATSetUObjectReferencesActor : AActor
{
	UPROPERTY()
	TSet<AActor> ActorReferences;

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
	}
}
/** @end */
