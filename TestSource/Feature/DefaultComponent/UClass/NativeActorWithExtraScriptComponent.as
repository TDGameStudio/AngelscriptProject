/**
 * An extra DefaultComponent on ACharacter. C++ checks that AExtendedCharacter
 * compiles and materializes. The observer covers the local construct default.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.NativeActorWithExtraScriptComponent
 * @Harness UClass
 * @Tag Feature.DefaultComponent.NativeActorWithExtraScriptComponent
 * @Provenance Theme: Feature.DefaultComponent. Positive extra DefaultComponent on ACharacter.
 * @Provenance C++: AngelscriptComponentTests.cpp::NativeActorWithExtraScriptComponent
 * @Provenance Oracle: AExtendedCharacter compiles and materializes. Extra: empty actor is null;
 * @Provenance ExtraMarker default handle is null. DefaultSafe.
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
