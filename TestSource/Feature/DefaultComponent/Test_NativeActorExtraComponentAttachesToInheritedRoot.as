// Theme: Feature.DefaultComponent. Positive extra DefaultComponent on a native Character.
// C++: AngelscriptComponentLifecycleExtendedTests.cpp::NativeActorExtraComponentAttachesToInheritedRoot
// Oracle after spawn: ExtraMarker is not the inherited root, ExtraMarker attach parent is
// the inherited root, ExtraMarker FName is ExtraMarker.
// Extra: empty actor handle is null. DefaultSafe.

UCLASS()
class ATestDefaultComponentExtendedNativeRoot : ACharacter
{
	UPROPERTY(DefaultComponent)
	USceneComponent ExtraMarker;
}

bool Observe_NativeRootExtra_EmptyDefaultIsNull()
{
	ATestDefaultComponentExtendedNativeRoot Actor;
	return Actor == nullptr;
}

bool Observe_NativeRootExtra_MarkerDefaultIsNull(ATestDefaultComponentExtendedNativeRoot Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0188 setup: required ATestDefaultComponentExtendedNativeRoot is null");
	}
	return Actor.ExtraMarker == nullptr;
}
