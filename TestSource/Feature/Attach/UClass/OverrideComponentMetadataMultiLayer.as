/**
 * OverrideComponent metadata inheritance across three layers. C++ checks
 * AMetaTopActor is a child of AMetaMidActor is a child of AMetaBaseActor.
 * The observers cover the local-construct default, the mid replacement null
 * boundary, and copy independence of two top actors.
 *
 * @Theme Feature.Attach
 * @Subject Attach.OverrideComponentMetadataMultiLayer
 * @Harness UClass
 * @Tag Feature.Attach.OverrideComponentMetadataMultiLayer
 * @Provenance Theme: Feature.Attach. WorldStory: OverrideComponent metadata inheritance across three layers.
 * @Provenance C++: AngelscriptComponentTests.cpp::OverrideComponentMetadataMultiLayer.
 * @Provenance Oracle: AMetaTopActor is a child of AMetaMidActor is a child of AMetaBaseActor.
 * @Provenance Extra: CDO component pointers may be null; copy independence of two top actors.
 * @Provenance FixtureIsolated. Keep RootScene, MetaChild, MidMetaReplacement, TopMetaExtra.
 */

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

	/**
	 * Observe that a locally constructed mid actor has not materialized the replacement.
	 *
	 * @Kind Observe
	 * @Covers Attach.OverrideComponentMetadataMultiLayer
	 * @Inputs a mid actor that has not been spawned
	 * @Return true when MidMetaReplacement is null
	 * @Boundary null override component
	 */
	UFUNCTION()
	bool MidNullBoundary()
	{
		return MidMetaReplacement == nullptr;
	}
}

UCLASS()
class AMetaTopActor : AMetaMidActor
{
	UPROPERTY(DefaultComponent)
	USceneComponent TopMetaExtra;

	/**
	 * Observe that a locally constructed top actor has not materialized any of the
	 * four component handles.
	 *
	 * @Kind Observe
	 * @Covers Attach.OverrideComponentMetadataMultiLayer
	 * @Inputs a top actor that has not been spawned
	 * @Return true when RootScene, MetaChild, MidMetaReplacement and TopMetaExtra are all null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RootScene != nullptr)
		{
			return false;
		}
		if (MetaChild != nullptr)
		{
			return false;
		}
		if (MidMetaReplacement != nullptr)
		{
			return false;
		}
		return TopMetaExtra == nullptr;
	}

	/**
	 * Observe that a second top instance is a different object.
	 *
	 * @Kind Observe
	 * @Covers Attach.OverrideComponentMetadataMultiLayer
	 * @Inputs this top actor plus a second top actor
	 * @Return true when the two actors are not the same object
	 * @Param Second the other top actor
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(AMetaTopActor Second)
	{
		if (Second is null)
		{
			throw("OverrideComponentMetadataMultiLayer setup: required Second is null");
		}
		return this != Second;
	}
}
