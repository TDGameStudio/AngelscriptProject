/**
 * Mixed DefaultComponent types including a script UActorComponent. After
 * BeginPlay, ComponentTypeCount is 4. Keep ComponentTypeCount.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ComponentTypes
 * @Harness UClass
 * @Tag Definitions.UClass.ComponentTypes
 * @Provenance Theme: Definitions.UClass. WorldStory mixed DefaultComponent types including a script UActorComponent.
 * @Provenance C++: AngelscriptCoverageClassFeaturesTests.cpp::ComponentTypes
 * @Provenance Oracle after BeginPlay: ComponentTypeCount=4. Extra: unset handle is null;
 * @Provenance pre-BeginPlay ComponentTypeCount=0. FixtureIsolated.
 */

UCLASS()
class UCoverageComponentTypesLogicComponent : UActorComponent
{
	/**
	 * Observe that an unset logic-component handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs an unset UCoverageComponentTypesLogicComponent handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		UCoverageComponentTypesLogicComponent Comp;
		return Comp == nullptr;
	}
}

UCLASS()
class AComponentTypesActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent SceneRoot;

	UPROPERTY(DefaultComponent, Attach=SceneRoot)
	UStaticMeshComponent StaticMesh;

	UPROPERTY(DefaultComponent, Attach=SceneRoot)
	USceneComponent ChildScene;

	UPROPERTY(DefaultComponent)
	UCoverageComponentTypesLogicComponent ActorComp;

	UPROPERTY()
	int ComponentTypeCount = 0;

	/**
	 * WorldStory: BeginPlay counts each materialized default component.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.DefaultComponent
	 * @Inputs SceneRoot, StaticMesh, ChildScene, ActorComp
	 * @Return ComponentTypeCount = 4 when all four exist
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (SceneRoot != nullptr)
			ComponentTypeCount++;
		if (StaticMesh != nullptr)
			ComponentTypeCount++;
		if (ChildScene != nullptr)
			ComponentTypeCount++;
		if (ActorComp != nullptr)
			ComponentTypeCount++;
	}

	/**
	 * Observe that an unset actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs an unset AComponentTypesActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		AComponentTypesActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe ComponentTypeCount before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.DefaultComponent
	 * @Inputs a freshly constructed actor
	 * @Return ComponentTypeCount
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int CountBeforeBeginPlay()
	{
		return ComponentTypeCount;
	}
}
