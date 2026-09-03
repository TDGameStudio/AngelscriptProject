/**
 * Live Actor handles on a TArray UPROPERTY. Needs World: SpawnActor and this.
 * Function _UObject covers NewObject handles only.
 *
 * @Theme Containers.TArray
 * @Subject TArray.ActorReferences
 * @Harness UClass
 * @Tag Containers.TArray.TArrayUObjectReferences
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

	/**
	 * WorldStory: self plus two spawned children; Contains(this); FindIndex(this) is 0.
	 *
	 * @Kind WorldStory
	 * @Covers TArray.Add
	 * @Inputs this; SpawnActor AActor at origin; SpawnActor AActor at (100,0,0)
	 * @Return ActorCount == 3, bContainsSelf == true; ActorCount == -1 if FindIndex(this) is not 0
	 */
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
