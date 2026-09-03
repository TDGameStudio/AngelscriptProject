/**
 * DefaultComponent on a non-component type is rejected. The property type must
 * be a component, not a primitive; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Negative_OnNonComponentType
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.Negative_OnNonComponentType
 * @Kind CompileReject
 * @Covers DefaultComponent.Negative_OnNonComponentType
 * @Inputs UPROPERTY(DefaultComponent) int X
 * @Return does not compile; DefaultComponent on non-component type should fail
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_OnNonComponentType
 * @Provenance AssertFailsToCompile module DefCompNonComp.
 * @Provenance Expected diagnostic: DefaultComponent on non-component type should fail.
 * @Provenance DiagnosticOnly. Isolation=none. Do not change X to a component type.
 */

class ADefCompNonCompActor : AActor
{
	UPROPERTY(DefaultComponent)
	int X;
}
