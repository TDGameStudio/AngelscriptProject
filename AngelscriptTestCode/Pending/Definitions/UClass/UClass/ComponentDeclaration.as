/**
 * @version v1
 * @summary DefaultComponent attach tree. After BeginPlay, ComponentCount is 23 (3 created + 10+10 attach). Keep ComponentCount.
 * @topic Definitions
 */
/**
 * @version root
 * @summary DefaultComponent attach tree. After BeginPlay, ComponentCount is 23 (3 created + 10+10 attach). Keep ComponentCount.
 * @topic Baseline
 */
UCLASS()
class AComponentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent ChildComponent;

	UPROPERTY(DefaultComponent, Attach=Root)
	UStaticMeshComponent MeshComponent;

	UPROPERTY()
	int ComponentCount = 0;

	/**
	 * WorldStory: BeginPlay counts created components and successful attaches.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.DefaultComponent
	 * @Inputs Root, ChildComponent, MeshComponent
	 * @Return ComponentCount = 23 when all three exist and both children attach to Root
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (Root != nullptr)
			ComponentCount++;
		if (ChildComponent != nullptr)
			ComponentCount++;
		if (MeshComponent != nullptr)
			ComponentCount++;

		if (ChildComponent != nullptr && ChildComponent.GetAttachParent() == Root)
			ComponentCount += 10;
		if (MeshComponent != nullptr && MeshComponent.GetAttachParent() == Root)
			ComponentCount += 10;
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs an unset AComponentActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		AComponentActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe ComponentCount before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs a freshly constructed actor
	 * @Return ComponentCount
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int CountBeforeBeginPlay()
	{
		return ComponentCount;
	}
}
/** @end */
