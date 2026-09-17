/**
 * @version v1
 * @summary HotReload version pair V2. C++ records that default/override metadata counts stay 2/1 and GetVersion() == 2. The layout RootScene / Billboard / ReplacementBillboard is retained; only the GetVersion body changes from 1 to.
 * @topic Feature
 */
/**
 * @version root
 * @summary HotReload version pair V2. C++ records that default/override metadata counts stay 2/1 and GetVersion() == 2. The layout RootScene / Billboard / ReplacementBillboard is retained; only the GetVersion body changes from 1 to.
 * @topic Baseline
 */
UCLASS()
class USoftMetadataRootComponent : USceneComponent
{
}

UCLASS()
class USoftMetadataBillboardComponent : UBillboardComponent
{
}

UCLASS()
class USoftMetadataReplacementBillboardComponent : USoftMetadataBillboardComponent
{
}

UCLASS()
class ASoftMetadataBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USoftMetadataRootComponent RootScene;

	UPROPERTY(DefaultComponent, Attach = RootScene)
	USoftMetadataBillboardComponent Billboard;
}

UCLASS()
class ASoftMetadataDerivedActor : ASoftMetadataBaseActor
{
	UPROPERTY(OverrideComponent = Billboard)
	USoftMetadataReplacementBillboardComponent ReplacementBillboard;

	/**
	 * Report the V2 metadata version.
	 *
	 * @Kind WorldStory
	 * @Covers DefaultComponent.SoftReloadMetadataVersion2
	 * @Inputs none
	 * @Return 2
	 */
	UFUNCTION()
	int GetVersion()
	{
		return 2;
	}

	/**
	 * Observe that a locally constructed derived actor has no replacement billboard.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.SoftReloadMetadataVersion2
	 * @Inputs an actor that has not been spawned
	 * @Return true when ReplacementBillboard is null
	 * @Boundary null override component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		return ReplacementBillboard == nullptr;
	}
}
/** @end */
