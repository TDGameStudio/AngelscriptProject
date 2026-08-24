// Theme: World.Component. WorldStory: GetComponent requires class and name.
// C++: AngelscriptActorComponentManagementTests.cpp::NameAndClassFilteringAreStrict
// sha256=b5b997a031fcdebaf06bad31a73f79bec22352677faba574e5b34f51529cc7cb; lines 246-276.
// Oracle RunNameClassFilterTest returns 1. Extra: local construct RootScene
// and MeshScene null. FixtureIsolated.

UCLASS()
class ATestActorComponentManagementNameClassFilter : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UStaticMeshComponent MeshScene;

	UFUNCTION()
	int RunNameClassFilterTest()
	{
		if (GetComponent(UStaticMeshComponent::StaticClass(), n"RootScene") != nullptr)
		{
			return 10;
		}

		if (GetComponent(USceneComponent::StaticClass(), n"MissingScene") != nullptr)
		{
			return 20;
		}

		UActorComponent RootByExactName = GetComponent(USceneComponent::StaticClass(), n"RootScene");
		if (RootByExactName == nullptr || RootByExactName != RootScene)
		{
			return 30;
		}

		UActorComponent MeshByExactName = GetComponent(UStaticMeshComponent::StaticClass(), n"MeshScene");
		if (MeshByExactName == nullptr || MeshByExactName != MeshScene)
		{
			return 40;
		}

		return 1;
	}
}

bool Observe_NameClassFilter_DefaultNull(ATestActorComponentManagementNameClassFilter Actor)
{
	if (Actor is null)
	{
		throw("Test_NameAndClassFilteringAreStrict setup: required Actor is null");
	}
	return Actor.RootScene == nullptr && Actor.MeshScene == nullptr;
}

bool Observe_NameClassFilter_CopyIndependence(ATestActorComponentManagementNameClassFilter First, ATestActorComponentManagementNameClassFilter Second)
{
	if (First is null)
	{
		throw("Test_NameAndClassFilteringAreStrict setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_NameAndClassFilteringAreStrict setup: required Second is null");
	}
	return First.RootScene == nullptr && Second.MeshScene == nullptr && First.MeshScene == nullptr;
}
