// Theme: World.Component. CSV NegativeDiagnostic; C++ compiles this actor
// then VerifyByPath. FindComponentByClass is a separate unsupported surface.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentFinding
// sha256=75380ae6e955db738532c6b8e08a3ca0efd71abc2d7a3a8f652f26ef10d469de; lines 1952-1990.
// Oracle after spawn+BeginPlay: FoundSingleComponent=true, SceneComponentCount=3.
// Extra: local construct FoundSingleComponent false, SceneComponentCount 0,
// DefaultComponent handles null. FixtureIsolated.

UCLASS()
class UCoverageFindingLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageComponentFindingActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child1;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child2;

	UPROPERTY(DefaultComponent)
	UCoverageFindingLogicComponent LogicComp;

	UPROPERTY()
	bool FoundSingleComponent = false;

	UPROPERTY()
	int SceneComponentCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UActorComponent FoundComp = GetComponentByClass(UActorComponent::StaticClass());
		FoundSingleComponent = (FoundComp != nullptr);

		TArray<USceneComponent> SceneComps;
		GetComponentsByClass(USceneComponent::StaticClass(), SceneComps);
		SceneComponentCount = SceneComps.Num();
	}
}

bool Observe_ComponentFinding_DefaultEmpty(ACoverageComponentFindingActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ComponentFinding setup: required Actor is null");
	}
	return !Actor.FoundSingleComponent
		&& Actor.SceneComponentCount == 0
		&& Actor.Root == nullptr
		&& Actor.Child1 == nullptr
		&& Actor.Child2 == nullptr
		&& Actor.LogicComp == nullptr;
}

bool Observe_ComponentFinding_CopyIndependence(ACoverageComponentFindingActor First, ACoverageComponentFindingActor Second)
{
	if (First is null)
	{
		throw("Test_ComponentFinding setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ComponentFinding setup: required Second is null");
	}
	First.FoundSingleComponent = true;
	First.SceneComponentCount = 3;
	return First.FoundSingleComponent
		&& First.SceneComponentCount == 3
		&& !Second.FoundSingleComponent
		&& Second.SceneComponentCount == 0;
}
