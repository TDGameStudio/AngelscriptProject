// Theme: Feature.Attach. WorldStory: OverrideComponent metadata inheritance across three layers.
// C++: AngelscriptComponentTests.cpp::OverrideComponentMetadataMultiLayer.
// Oracle: AMetaTopActor is a child of AMetaMidActor is a child of AMetaBaseActor.
// Extra: CDO component pointers may be null; copy independence of two top actors.
// FixtureIsolated. Keep RootScene, MetaChild, MidMetaReplacement, TopMetaExtra.

UCLASS()
class AMetaBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USceneComponent MetaChild;
}

UCLASS()
class AMetaMidActor : AMetaBaseActor
{
	UPROPERTY(OverrideComponent = MetaChild)
	UStaticMeshComponent MidMetaReplacement;
}

UCLASS()
class AMetaTopActor : AMetaMidActor
{
	UPROPERTY(DefaultComponent)
	USceneComponent TopMetaExtra;
}

bool Observe_MetaMultiLayer_EmptyDefault(AMetaTopActor Actor)
{
	if (Actor is null)
	{
		throw("Test_OverrideComponentMetadataMultiLayer setup: required Actor is null");
	}
	return Actor.RootScene == nullptr
		&& Actor.MetaChild == nullptr
		&& Actor.MidMetaReplacement == nullptr
		&& Actor.TopMetaExtra == nullptr;
}

bool Observe_MetaMultiLayer_MidNullBoundary(AMetaMidActor Mid)
{
	if (Mid is null)
	{
		throw("Test_OverrideComponentMetadataMultiLayer setup: required Mid is null");
	}
	return Mid.MidMetaReplacement == nullptr;
}

bool Observe_MetaMultiLayer_CopyIndependence()
{
	AMetaTopActor First;
	AMetaTopActor Second;
	return First != Second;
}
