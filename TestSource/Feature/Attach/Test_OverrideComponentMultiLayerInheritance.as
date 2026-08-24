// Theme: Feature.Attach. WorldStory: OverrideComponent across base/mid/top actor layers.
// C++: AngelscriptComponentTests.cpp::OverrideComponentMultiLayerInheritance.
// Oracle: ATopLayerActor materializes; MidReplacement overrides BaseChild; TopExtra is an extra default.
// Extra: CDO component pointers may be null; copy independence of two top actors.
// FixtureIsolated. Keep RootScene, BaseChild, MidReplacement, TopExtra.

UCLASS()
class ABaseLayerActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USceneComponent BaseChild;
}

UCLASS()
class AMidLayerActor : ABaseLayerActor
{
	UPROPERTY(OverrideComponent = BaseChild)
	UStaticMeshComponent MidReplacement;
}

UCLASS()
class ATopLayerActor : AMidLayerActor
{
	UPROPERTY(DefaultComponent)
	USceneComponent TopExtra;
}

bool Observe_MultiLayer_EmptyDefault(ATopLayerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_OverrideComponentMultiLayerInheritance setup: required Actor is null");
	}
	return Actor.RootScene == nullptr
		&& Actor.BaseChild == nullptr
		&& Actor.MidReplacement == nullptr
		&& Actor.TopExtra == nullptr;
}

bool Observe_MultiLayer_MidReplacementNullBoundary(AMidLayerActor Mid)
{
	if (Mid is null)
	{
		throw("Test_OverrideComponentMultiLayerInheritance setup: required Mid is null");
	}
	return Mid.MidReplacement == nullptr;
}

bool Observe_MultiLayer_CopyIndependence()
{
	ATopLayerActor First;
	ATopLayerActor Second;
	return First != Second;
}
