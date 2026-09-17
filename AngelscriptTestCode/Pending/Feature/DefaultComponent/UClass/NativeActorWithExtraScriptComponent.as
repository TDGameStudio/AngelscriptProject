/**
 * @version v1
 * @summary An extra DefaultComponent on ACharacter. C++ checks that AExtendedCharacter compiles and materializes. The observer covers the local construct default.
 * @topic Feature
 */
/**
 * @version root
 * @summary An extra DefaultComponent on ACharacter. C++ checks that AExtendedCharacter compiles and materializes. The observer covers the local construct default.
 * @topic Baseline
 */
UCLASS()
class AExtendedCharacter : ACharacter
{
	UPROPERTY(DefaultComponent)
	USceneComponent ExtraMarker;

	/**
	 * Observe that a locally constructed character has no ExtraMarker.
	 *
	 * @Kind Observe
	 * @Covers DefaultComponent.NativeActorWithExtraScriptComponent
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
