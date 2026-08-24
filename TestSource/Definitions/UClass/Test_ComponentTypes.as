// Theme: Definitions.UClass. WorldStory mixed DefaultComponent types including a script UActorComponent.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::ComponentTypes
// Oracle after BeginPlay: ComponentTypeCount=4. Extra: unset handle is null;
// pre-BeginPlay ComponentTypeCount=0. FixtureIsolated.

UCLASS()
class UCoverageComponentTypesLogicComponent : UActorComponent
{
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
}

bool Observe_ComponentTypes_EmptyDefaultIsNull()
{
	AComponentTypesActor Actor;
	return Actor == nullptr;
}

int Observe_ComponentTypes_CountBeforeBeginPlay(AComponentTypesActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0037 setup: required AComponentTypesActor is null");
	}
	return Actor.ComponentTypeCount;
}

bool Observe_LogicComponent_EmptyDefaultIsNull()
{
	UCoverageComponentTypesLogicComponent Comp;
	return Comp == nullptr;
}
