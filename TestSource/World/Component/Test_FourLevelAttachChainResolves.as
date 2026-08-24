// Theme: World.Component. WorldStory: four-level DefaultComponent attach chain.
// C++: AngelscriptComponentMultiLevelHierarchyTests.cpp::FourLevelAttachChainResolves
// spawn AFunctionalMultiLevelActor then C++ walks Root/Middle/LeafMesh/DeepLight parents.
// Keep UPROPERTY names Root, Middle, LeafMesh, DeepLight.
// sha256=34bd6c2ed244b2a4963d8cbaf064e15541ac1e585a64e68201cd24655c67666a; lines 34-50.
// Extra: local construct leaves all four handles null; a second instance stays independent null.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class AFunctionalMultiLevelActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach = Root)
	USceneComponent Middle;

	UPROPERTY(DefaultComponent, Attach = Middle)
	UStaticMeshComponent LeafMesh;

	UPROPERTY(DefaultComponent, Attach = LeafMesh)
	UPointLightComponent DeepLight;
}

bool Observe_FourLevelAttach_DefaultComponentsNull(AFunctionalMultiLevelActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FourLevelAttachChainResolves setup: required Actor is null");
	}
	return Actor.Root == nullptr
		&& Actor.Middle == nullptr
		&& Actor.LeafMesh == nullptr
		&& Actor.DeepLight == nullptr;
}

bool Observe_FourLevelAttach_CopyIndependence(AFunctionalMultiLevelActor First, AFunctionalMultiLevelActor Second)
{
	if (First is null)
	{
		throw("Test_FourLevelAttachChainResolves setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FourLevelAttachChainResolves setup: required Second is null");
	}
	return First.Root == nullptr && Second.Root == nullptr
		&& First.Middle == nullptr && Second.Middle == nullptr
		&& First.LeafMesh == nullptr && Second.LeafMesh == nullptr
		&& First.DeepLight == nullptr && Second.DeepLight == nullptr;
}
