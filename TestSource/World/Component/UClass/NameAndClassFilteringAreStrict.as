/**
 * GetComponent requiring both a class and a name to agree. C++ runs
 * RunNameClassFilterTest and expects 1. The observers cover the local-construct
 * default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.NameAndClassFilteringAreStrict
 * @Harness UClass
 * @Tag World.Component.NameAndClassFilteringAreStrict
 * @Provenance Theme: World.Component. WorldStory: GetComponent requires class and name.
 * @Provenance C++: AngelscriptActorComponentManagementTests.cpp::NameAndClassFilteringAreStrict
 * @Provenance sha256=b5b997a031fcdebaf06bad31a73f79bec22352677faba574e5b34f51529cc7cb; lines 246-276.
 * @Provenance Oracle RunNameClassFilterTest returns 1. Extra: local construct RootScene
 * @Provenance and MeshScene null. FixtureIsolated.
 */

UCLASS()
class ATestActorComponentManagementNameClassFilter : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UStaticMeshComponent MeshScene;

	/**
	 * Walk the four filtering vectors: wrong class, missing name, and both exact
	 * matches.
	 *
	 * @Kind Observe
	 * @Covers Component.NameAndClassFilteringAreStrict
	 * @Inputs none
	 * @Return 1 on success; 10, 20, 30 or 40 naming the step that failed
	 */
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

	/**
	 * Observe that a locally constructed actor has neither component.
	 *
	 * @Kind Observe
	 * @Covers Component.NameAndClassFilteringAreStrict
	 * @Inputs an actor that has not been spawned
	 * @Return true when both scene components are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultNull()
	{
		if (RootScene != nullptr)
		{
			return false;
		}
		return MeshScene == nullptr;
	}

	/**
	 * Observe that a second instance keeps its own independent null handles.
	 *
	 * @Kind Observe
	 * @Covers Component.NameAndClassFilteringAreStrict
	 * @Inputs this actor plus a second actor
	 * @Return true when all four handles are null
	 * @Param Second the other actor, also expected to hold null handles
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ATestActorComponentManagementNameClassFilter Second)
	{
		if (Second is null)
		{
			throw("NameAndClassFilteringAreStrict setup: required Second is null");
		}
		if (RootScene != nullptr)
		{
			return false;
		}
		if (Second.MeshScene != nullptr)
		{
			return false;
		}
		return MeshScene == nullptr;
	}
}
