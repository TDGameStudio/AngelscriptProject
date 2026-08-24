// Theme: Feature.DefaultComponent. Positive extra DefaultComponent on ACharacter.
// C++: AngelscriptComponentTests.cpp::NativeActorWithExtraScriptComponent
// Oracle: AExtendedCharacter compiles and materializes. Extra: empty actor is null;
// ExtraMarker default handle is null. DefaultSafe.

UCLASS()
class AExtendedCharacter : ACharacter
{
	UPROPERTY(DefaultComponent)
	USceneComponent ExtraMarker;
}

bool Observe_ExtendedCharacter_EmptyDefaultIsNull()
{
	AExtendedCharacter Actor;
	return Actor == nullptr;
}

bool Observe_ExtendedCharacter_MarkerDefaultIsNull(AExtendedCharacter Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0195 setup: required AExtendedCharacter is null");
	}
	return Actor.ExtraMarker == nullptr;
}
