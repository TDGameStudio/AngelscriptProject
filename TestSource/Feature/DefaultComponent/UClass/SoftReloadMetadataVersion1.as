/**
 * HotReload version pair V1. C++ records two default-component entries and one
 * override entry, with GetVersion() == 1. The layout RootScene / Billboard /
 * ReplacementBillboard is retained after reload; GetVersion is replaced later.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.SoftReloadMetadataVersion1
 * @Harness UClass
 * @Tag Feature.DefaultComponent.SoftReloadMetadataVersion1
 * @Provenance Theme: Feature.DefaultComponent. HotReload version pair V1.
 * @Provenance C++: AngelscriptASClassComponentMetadataTests.cpp::SoftReloadPreservesDefaultComponentMetadataWithoutDuplication block 1
 * @Provenance Oracle: two default-component entries, one override entry; GetVersion()==1.
 * @Provenance Retained after reload: RootScene / Billboard / ReplacementBillboard layout.
 * @Provenance Replaced later: GetVersion body. Extra: empty actor is null. FixtureIsolated.
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
	 * Report the V1 metadata version.
	 *
	 * @Kind WorldStory
	 * @Covers DefaultComponent.SoftReloadMetadataVersion1
	 * @Inputs none
	 * @Return 1
	 */
	UFUNCTION()
	int GetVersion()
	{
		return 1;
	}

	/**
	 * Observe that a locally constructed derived actor has no replacement billboard.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.SoftReloadMetadataVersion1
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
