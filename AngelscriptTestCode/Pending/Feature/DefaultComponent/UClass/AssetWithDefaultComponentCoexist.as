/**
 * @version v1
 * @summary A literal asset coexists with a DefaultComponent actor. C++ materializes AAssetAndComponentActor and UAssetCarrier; MyCoexistAsset CoexistMarker is 99. The observers cover the local construct default of both types.
 * @topic Feature
 */
/**
 * @version root
 * @summary A literal asset coexists with a DefaultComponent actor. C++ materializes AAssetAndComponentActor and UAssetCarrier; MyCoexistAsset CoexistMarker is 99. The observers cover the local construct default of both types.
 * @topic Baseline
 */
UCLASS()
class UAssetCarrier : UObject
{
	UPROPERTY()
	int CoexistMarker = 0;

	/**
	 * Observe the class default of CoexistMarker on a locally constructed carrier.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.AssetWithDefaultComponentCoexist
	 * @Inputs a carrier that has not been filled by the asset
	 * @Return CoexistMarker, expected to be 0
	 * @Boundary class default
	 */
	UFUNCTION()
	int CoexistMarkerDefault()
	{
		return CoexistMarker;
	}
}

UCLASS()
class AAssetAndComponentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	/**
	 * Observe that a locally constructed actor has no RootScene.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.AssetWithDefaultComponentCoexist
	 * @Inputs an actor that has not been spawned
	 * @Return true when RootScene is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		return RootScene == nullptr;
	}
}

asset MyCoexistAsset of UAssetCarrier
{
	CoexistMarker = 99;
}
/** @end */
