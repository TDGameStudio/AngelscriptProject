// Theme: Definitions.UClass. Isolated compile-fail: DefaultComponent+ShowOnActor on a plain UObject.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: does not derive from UActorComponent.
// DiagnosticOnly. Do not change PlainObject to a component type; that would make the program compile.

UCLASS()
class UCoverageUClassShowOnActorPlainObject : UObject
{
}

UCLASS()
class ACoverageUClassShowOnActorInstancedObjectActor : AActor
{
	UPROPERTY(DefaultComponent, ShowOnActor)
	UCoverageUClassShowOnActorPlainObject PlainObject;
}
