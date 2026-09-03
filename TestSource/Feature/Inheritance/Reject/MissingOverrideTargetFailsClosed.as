/**
 * OverrideComponent naming a base component that does not exist is rejected.
 * The isolated failure is OverrideComponent = MissingScene; dropping that
 * specifier would make the program compile.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.MissingOverrideTargetFailsClosed
 * @Harness CompileReject
 * @Tag Feature.Inheritance.MissingOverrideTargetFailsClosed
 * @Kind CompileReject
 * @Covers Inheritance.MissingOverrideTargetFailsClosed
 * @Inputs UPROPERTY(OverrideComponent = MissingScene) ReplacementRoot
 * @Return does not compile; "OverrideComponent ADerivedOverrideMissing::ReplacementRoot could not find component MissingScene in base class to override."
 * @Provenance Theme: Feature.Inheritance. Isolated compile-fail: OverrideComponent target missing on the base.
 * @Provenance C++: AngelscriptComponentMetadataValidationTests.cpp::MissingOverrideTargetFailsClosed
 * @Provenance Observation.bCompiled false. Expected diagnostic:
 * @Provenance "OverrideComponent ADerivedOverrideMissing::ReplacementRoot could not find component MissingScene in base class to override."
 * @Provenance DiagnosticOnly. Do not drop OverrideComponent = MissingScene; that would make the program compile.
 */

UCLASS()
class UBaseOverrideMissingRoot : USceneComponent
{
}

UCLASS()
class UDerivedOverrideMissingRoot : UBaseOverrideMissingRoot
{
}

UCLASS()
class ABaseOverrideMissing : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UBaseOverrideMissingRoot RootScene;
}

UCLASS()
class ADerivedOverrideMissing : ABaseOverrideMissing
{
	UPROPERTY(OverrideComponent = MissingScene)
	UDerivedOverrideMissingRoot ReplacementRoot;
}
