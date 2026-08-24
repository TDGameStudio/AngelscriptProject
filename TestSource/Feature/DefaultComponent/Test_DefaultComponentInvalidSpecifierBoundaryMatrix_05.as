// Theme: Feature.DefaultComponent. Isolated compile-fail: DefaultComponent on a plain UObject.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
// CompileFixtureShouldFail. Expected diagnostic: "does not derive from UActorComponent".
// DiagnosticOnly. Do not change PlainObject to a component type.

UCLASS()
class UCoverageUClassDefaultComponentPlainObject : UObject
{
}

UCLASS()
class ACoverageUClassDefaultComponentNonComponent : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassDefaultComponentPlainObject PlainObject;
}
