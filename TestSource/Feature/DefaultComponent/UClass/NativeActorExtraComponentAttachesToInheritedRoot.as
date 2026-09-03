/**
 * An extra DefaultComponent on a native Character. C++ checks that ExtraMarker
 * is not the inherited root, attaches to that root, and is named ExtraMarker.
 * The observer covers the local construct default.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.NativeActorExtraComponentAttachesToInheritedRoot
 * @Harness UClass
 * @Tag Feature.DefaultComponent.NativeActorExtraComponentAttachesToInheritedRoot
 * @Provenance Theme: Feature.DefaultComponent. Positive extra DefaultComponent on a native Character.
 * @Provenance C++: AngelscriptComponentLifecycleExtendedTests.cpp::NativeActorExtraComponentAttachesToInheritedRoot
 * @Provenance Oracle after spawn: ExtraMarker is not the inherited root, ExtraMarker attach parent is
 * @Provenance the inherited root, ExtraMarker FName is ExtraMarker.
 * @Provenance Extra: empty actor handle is null. DefaultSafe.
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
