/**
 * @version v1
 * @summary An extra DefaultComponent on a native Character. C++ checks that ExtraMarker is not the inherited root, attaches to that root, and is named ExtraMarker. The observer covers the local construct default.
 * @topic Feature
 */
/**
 * @version root
 * @summary An extra DefaultComponent on a native Character. C++ checks that ExtraMarker is not the inherited root, attaches to that root, and is named ExtraMarker. The observer covers the local construct default.
 * @topic Baseline
 */
UCLASS()
class ATestDefaultComponentExtendedNativeRoot : ACharacter
{
	UPROPERTY(DefaultComponent)
	USceneComponent ExtraMarker;

	/**
	 * Observe that a locally constructed character has no ExtraMarker.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.NativeActorExtraComponentAttachesToInheritedRoot
	 * @Inputs a character that has not been spawned
	 * @Return true when ExtraMarker is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		return ExtraMarker == nullptr;
	}
}
/** @end */
