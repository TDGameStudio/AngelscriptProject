/**
 * Live Actor handles on a TMap UPROPERTY. Needs World: SpawnActor and this.
 * Function _UObject covers NewObject handles only.
 *
 * @Theme Containers.TMap
 * @Subject TMap.ActorReferences
 * @Harness UClass
 * @Tag Containers.TMap.TMapUObjectReferences
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

	/**
	 * WorldStory: self plus two spawned children; Contains(0); [0] is this.
	 *
	 * @Kind WorldStory
	 * @Covers TMap.Add
	 * @Inputs this; SpawnActor AActor at origin; SpawnActor AActor at (100,0,0)
	 * @Return ActorCount == 3, bContainsSelf == true; ActorCount == -1 if [0] is not this
	 */
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
