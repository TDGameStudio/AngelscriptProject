/**
 * @version v1
 * @summary Live Actor handles on a TSet UPROPERTY. Needs World: SpawnActor and this. Function _UObject covers NewObject handles only.
 * @topic Containers
 */
/**
 * @version root
 * @summary Live Actor handles on a TSet UPROPERTY. Needs World: SpawnActor and this. Function _UObject covers NewObject handles only.
 * @topic Baseline
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

	/**
	 * WorldStory: self plus two spawned children; Contains(this).
	 *
	 * @Kind WorldStory
	 * @Covers TSet.Add
	 * @Inputs this; SpawnActor AActor at origin; SpawnActor AActor at (100,0,0)
	 * @Return ActorCount == 3, bContainsSelf == true
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
	}
}
/** @end */
