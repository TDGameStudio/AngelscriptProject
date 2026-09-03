/**
 * A concrete actor that inherits an abstract DefaultComponent without an
 * OverrideComponent is rejected. The missing override is the isolated failure;
 * adding one would make the program compile.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.AbstractBaseComponentRequiresConcreteOverride
 * @Harness CompileReject
 * @Tag Feature.Inheritance.AbstractBaseComponentRequiresConcreteOverride
 * @Kind CompileReject
 * @Covers Inheritance.AbstractBaseComponentRequiresConcreteOverride
 * @Inputs AComponentVerifyClassConcreteMissingOverrideActor : AComponentVerifyClassAbstractBaseActor
 * @Return does not compile; missing abstract-component override diagnostic;
 * @Return AComponentVerifyClassConcreteMissingOverrideActor is not published
 * @Provenance Theme: Feature.Inheritance. Isolated compile-fail: concrete actor inherits an abstract DefaultComponent.
 * @Provenance C++: AngelscriptComponentMetadataValidationTests.cpp::AbstractBaseComponentRequiresConcreteOverride
 * @Provenance Observation.bCompiled false. Expected: missing abstract-component override error diagnostic;
 * @Provenance AComponentVerifyClassConcreteMissingOverrideActor is not published.
 * @Provenance DiagnosticOnly. Do not add an OverrideComponent; that would make the program compile.
 */

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
