/**
 * DefaultComponent on a non-UActorComponent type is rejected. The property type
 * must be a component; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Negative_BadComponentType
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.Negative_BadComponentType
 * @Kind CompileReject
 * @Covers DefaultComponent.Negative_BadComponentType
 * @Inputs UPROPERTY(DefaultComponent) AActor SubActor
 * @Return does not compile; DefaultComponent on non-UActorComponent type should fail
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_BadComponentType
 * @Provenance AssertFailsToCompile module DefCompBadCompType.
 * @Provenance Expected diagnostic: DefaultComponent on non-UActorComponent type should fail.
 * @Provenance DiagnosticOnly. Isolation=none. Do not change SubActor to a component type.
 */

class ADefCompBadTypeActor : AActor
{
	UPROPERTY(DefaultComponent)
	AActor SubActor;
}
