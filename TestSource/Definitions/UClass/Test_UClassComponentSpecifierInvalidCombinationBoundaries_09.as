// Theme: Definitions.UClass. Isolated compile-fail: DefaultComponent on a plain UObject.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: does not derive from UActorComponent.
// DiagnosticOnly. Do not change PlainObject to a component type; that would make the program compile.

UCLASS()
class UCoverageUClassPlainDefaultObject : UObject
{
}

UCLASS()
class ACoverageUClassNonComponentDefaultActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassPlainDefaultObject PlainObject;
}
