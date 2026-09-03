/**
 * RootComponent plus Attach=RootScene default components. RootScene is the root
 * and Billboard attaches to it. Keep RootScene and Billboard names.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.ValidRootAndAttachedSceneComponentsPublishMetadata
 * @Harness UClass
 * @Tag Definitions.Meta.ValidRootAndAttachedSceneComponentsPublishMetadata
 * @Provenance Theme: Definitions.Meta. WorldStory: RootComponent plus Attach=RootScene default components.
 * @Provenance C++: AngelscriptComponentMetadataValidationTests.cpp::ValidRootAndAttachedSceneComponentsPublishMetadata
 * @Provenance Oracle: RootScene is root; Billboard attaches to RootScene. Extra: default handle is null.
 * @Provenance FixtureIsolated. Keep RootScene / Billboard names.
 */

UCLASS()
class AComponentVerifyClassValidActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UBillboardComponent Billboard;

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Meta.ValidRootAndAttachedSceneComponentsPublishMetadata
	 * @Inputs an unset actor handle
	 * @Return 1 when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	int EmptyDefaultIsNull()
	{
		AComponentVerifyClassValidActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that assigning one unset handle aliases the other.
	 *
	 * @Kind Observe
	 * @Covers Meta.ValidRootAndAttachedSceneComponentsPublishMetadata
	 * @Inputs none
	 * @Return true when the assigned handles compare identical
	 * @Boundary assign aliases
	 */
	UFUNCTION()
	bool AssignAliases()
	{
		AComponentVerifyClassValidActor First;
		AComponentVerifyClassValidActor Second;
		First = Second;
		return First is Second;
	}

	/**
	 * Observe that RootScene and Billboard are present.
	 *
	 * @Kind Observe
	 * @Covers Meta.ValidRootAndAttachedSceneComponentsPublishMetadata
	 * @Inputs none
	 * @Return true when both components are not null
	 */
	UFUNCTION()
	bool RootAndBillboardPresent()
	{
		if (RootScene == nullptr)
		{
			return false;
		}
		return Billboard != nullptr;
	}

	/**
	 * Observe that Billboard attaches to RootScene.
	 *
	 * @Kind Observe
	 * @Covers Meta.ValidRootAndAttachedSceneComponentsPublishMetadata
	 * @Inputs none
	 * @Return true when Billboard's attach parent is RootScene
	 */
	UFUNCTION()
	bool BillboardAttachedToRoot()
	{
		if (RootScene == nullptr)
		{
			return false;
		}
		if (Billboard == nullptr)
		{
			return false;
		}
		return Billboard.GetAttachParent() == RootScene;
	}
}
