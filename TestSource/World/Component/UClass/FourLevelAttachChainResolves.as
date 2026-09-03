/**
 * A four-level DefaultComponent attach chain. C++ spawns the actor and walks the
 * parents of Root, Middle, LeafMesh and DeepLight. The observers cover the
 * local-construct default and copy independence.
 *
 * @Theme World.Component
 * @Subject Component.FourLevelAttachChain
 * @Harness UClass
 * @Tag World.Component.FourLevelAttachChainResolves
 * @Provenance Theme: World.Component. WorldStory: four-level DefaultComponent attach chain.
 * @Provenance C++: AngelscriptComponentMultiLevelHierarchyTests.cpp::FourLevelAttachChainResolves
 * @Provenance spawn AFunctionalMultiLevelActor then C++ walks Root/Middle/LeafMesh/DeepLight parents.
 * @Provenance Keep UPROPERTY names Root, Middle, LeafMesh, DeepLight.
 * @Provenance sha256=34bd6c2ed244b2a4963d8cbaf064e15541ac1e585a64e68201cd24655c67666a; lines 34-50.
 * @Provenance Extra: local construct leaves all four handles null; a second instance stays independent null.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

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

	/**
	 * Observe that a locally constructed actor has none of the four components.
	 *
	 * @Kind Observe
	 * @Covers Component.FourLevelAttachChain
	 * @Inputs an actor that has not been spawned
	 * @Return true when all four handles are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultComponentsNull()
	{
		if (Root != nullptr)
		{
			return false;
		}
		if (Middle != nullptr)
		{
			return false;
		}
		if (LeafMesh != nullptr)
		{
			return false;
		}
		return DeepLight == nullptr;
	}

	/**
	 * Observe that a second instance keeps its own independent null handles.
	 *
	 * @Kind Observe
	 * @Covers Component.FourLevelAttachChain
	 * @Inputs this actor plus a second actor
	 * @Return true when all eight handles are null
	 * @Param Second the other actor, also expected to hold null handles
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AFunctionalMultiLevelActor Second)
	{
		if (Second is null)
		{
			throw("FourLevelAttachChainResolves setup: required Second is null");
		}
		if (Root != nullptr)
		{
			return false;
		}
		if (Second.Root != nullptr)
		{
			return false;
		}
		if (Middle != nullptr)
		{
			return false;
		}
		if (Second.Middle != nullptr)
		{
			return false;
		}
		if (LeafMesh != nullptr)
		{
			return false;
		}
		if (Second.LeafMesh != nullptr)
		{
			return false;
		}
		if (DeepLight != nullptr)
		{
			return false;
		}
		return Second.DeepLight == nullptr;
	}
}
