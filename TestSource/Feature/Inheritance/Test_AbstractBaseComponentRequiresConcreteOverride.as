// Theme: Feature.Inheritance. Isolated compile-fail: concrete actor inherits an abstract DefaultComponent.
// C++: AngelscriptComponentMetadataValidationTests.cpp::AbstractBaseComponentRequiresConcreteOverride
// Observation.bCompiled false. Expected: missing abstract-component override error diagnostic;
// AComponentVerifyClassConcreteMissingOverrideActor is not published.
// DiagnosticOnly. Do not add an OverrideComponent; that would make the program compile.

UCLASS(Abstract)
class AComponentVerifyClassAbstractBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UAngelscriptVerifyClassAbstractSceneComponent AbstractRoot;
}

UCLASS()
class AComponentVerifyClassConcreteMissingOverrideActor : AComponentVerifyClassAbstractBaseActor
{
}
