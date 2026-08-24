// Theme: Definitions.UClass. WorldStory UObject/AActor/UActorComponent/USceneComponent UCLASS bases.
// C++: AngelscriptCoverageUClassTests.cpp::UClassBaseTypeDeclarations
// Oracle: each generated class is a child of the matching native base.
// Extra: unset handles are null; assign aliases. FixtureIsolated.

UCLASS()
class UCoverageUClassBaseObject : UObject
{
}

UCLASS()
class ACoverageUClassBaseActor : AActor
{
}

UCLASS()
class UCoverageUClassBaseActorComponent : UActorComponent
{
}

UCLASS()
class UCoverageUClassBaseSceneComponent : USceneComponent
{
}

bool Observe_BaseObject_EmptyDefaultIsNull()
{
	UCoverageUClassBaseObject Obj;
	return Obj == nullptr;
}

bool Observe_BaseActor_EmptyDefaultIsNull()
{
	ACoverageUClassBaseActor Actor;
	return Actor == nullptr;
}

bool Observe_BaseActorComponent_EmptyDefaultIsNull()
{
	UCoverageUClassBaseActorComponent Comp;
	return Comp == nullptr;
}

bool Observe_BaseSceneComponent_EmptyDefaultIsNull()
{
	UCoverageUClassBaseSceneComponent Comp;
	return Comp == nullptr;
}

bool Observe_BaseActor_AssignAliases()
{
	ACoverageUClassBaseActor First;
	ACoverageUClassBaseActor Second;
	First = Second;
	return First is Second;
}
