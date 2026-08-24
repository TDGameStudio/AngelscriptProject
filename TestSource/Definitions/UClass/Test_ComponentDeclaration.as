// Theme: Definitions.UClass. WorldStory DefaultComponent attach tree.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::ComponentDeclaration
// Oracle after BeginPlay: ComponentCount=23 (3 created + 10+10 attach).
// Extra: unset handle is null; pre-BeginPlay ComponentCount=0. FixtureIsolated.

UCLASS()
class AComponentActor : AActor
{
	// Root component
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	// Attached to root
	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent ChildComponent;

	// Static mesh component
	UPROPERTY(DefaultComponent, Attach=Root)
	UStaticMeshComponent MeshComponent;

	UPROPERTY()
	int ComponentCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Count initialized components
		if (Root != nullptr)
			ComponentCount++;
		if (ChildComponent != nullptr)
			ComponentCount++;
		if (MeshComponent != nullptr)
			ComponentCount++;

		// Verify attachment
		if (ChildComponent != nullptr && ChildComponent.GetAttachParent() == Root)
			ComponentCount += 10;
		if (MeshComponent != nullptr && MeshComponent.GetAttachParent() == Root)
			ComponentCount += 10;
	}
}

bool Observe_ComponentActor_EmptyDefaultIsNull()
{
	AComponentActor Actor;
	return Actor == nullptr;
}

int Observe_ComponentActor_CountBeforeBeginPlay(AComponentActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0035 setup: required AComponentActor is null");
	}
	return Actor.ComponentCount;
}
