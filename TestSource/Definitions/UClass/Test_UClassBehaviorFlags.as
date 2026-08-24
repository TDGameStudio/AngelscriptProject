// Theme: Definitions.UClass. WorldStory Transient/Deprecated/NotPlaceable vs default-placeable actor.
// C++: AngelscriptCoverageUClassTests.cpp::UClassBehaviorFlags
// Oracle: Transient+Deprecated flags; NotPlaceable CLASS_NotPlaceable; default actor is placeable.
// Extra: unset handles are null. FixtureIsolated.

UCLASS(Transient, Deprecated)
class UCoverageUClassTransientDeprecatedObject : UObject
{
}

UCLASS(NotPlaceable)
class ACoverageUClassNotPlaceableActor : AActor
{
}

UCLASS()
class ACoverageUClassDefaultPlaceableActor : AActor
{
}

bool Observe_TransientDeprecated_EmptyDefaultIsNull()
{
	UCoverageUClassTransientDeprecatedObject Obj;
	return Obj == nullptr;
}

bool Observe_NotPlaceableActor_EmptyDefaultIsNull()
{
	ACoverageUClassNotPlaceableActor Actor;
	return Actor == nullptr;
}

bool Observe_DefaultPlaceableActor_EmptyDefaultIsNull()
{
	ACoverageUClassDefaultPlaceableActor Actor;
	return Actor == nullptr;
}

bool Observe_DefaultPlaceableActor_AssignAliases()
{
	ACoverageUClassDefaultPlaceableActor First;
	ACoverageUClassDefaultPlaceableActor Second;
	First = Second;
	return First is Second;
}
