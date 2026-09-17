/**
 * @version v1
 * @summary DefaultComponent plus OverrideComponent metadata. C++ records two default components on the base (RootScene is root, Billboard attaches to RootScene) and one override on the derived (ReplacementBillboard overrides.
 * @topic Feature
 */
/**
 * @version root
 * @summary DefaultComponent plus OverrideComponent metadata. C++ records two default components on the base (RootScene is root, Billboard attaches to RootScene) and one override on the derived (ReplacementBillboard overrides.
 * @topic Baseline
 */
UCLASS()
class UMetadataRootComponent : USceneComponent
{
}

UCLASS()
class UMetadataBillboardComponent : UBillboardComponent
{
}

UCLASS()
class UMetadataReplacementBillboardComponent : UMetadataBillboardComponent
{
}

UCLASS()
class AMetadataBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UMetadataRootComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	UMetadataBillboardComponent Billboard;

	/**
	 * Observe that a locally constructed base actor has neither default component.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentMetadataCapturesRootAndAttachLayout
	 * @Inputs a base actor that has not been spawned
	 * @Return true when RootScene and Billboard are null
	 * @Boundary null default components
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (RootScene != nullptr)
		{
			return false;
		}
		return Billboard == nullptr;
	}
}

UCLASS()
class AMetadataDerivedActor : AMetadataBaseActor
{
	UPROPERTY(OverrideComponent = Billboard)
	UMetadataReplacementBillboardComponent ReplacementBillboard;

	/**
	 * Observe that a locally constructed derived actor has no replacement billboard.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.DefaultComponentMetadataCapturesRootAndAttachLayout
	 * @Inputs a derived actor that has not been spawned
	 * @Return true when ReplacementBillboard is null
	 * @Boundary null override component
	 */
	UFUNCTION()
	bool ReplacementDefaultEmpty()
	{
		return ReplacementBillboard == nullptr;
	}
}
/** @end */
