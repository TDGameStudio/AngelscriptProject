/**
 * DefaultComponent of a type that does not exist is rejected. The property type
 * must name a real component class; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Negative_DefaultComponentOnNonExistentType
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.Negative_DefaultComponentOnNonExistentType
 * @Kind CompileReject
 * @Covers DefaultComponent.Negative_DefaultComponentOnNonExistentType
 * @Inputs UPROPERTY(DefaultComponent) UNonExistentComponent Comp
 * @Return does not compile; DefaultComponent with non-existent component type should fail
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_DefaultComponentOnNonExistentType
 * @Provenance AssertFailsToCompile module DefCompBadType.
 * @Provenance Expected diagnostic: DefaultComponent with non-existent component type should fail.
 * @Provenance DiagnosticOnly. Isolation=none. Do not declare UNonExistentComponent.
 */

class ADefCompBadTypeNameActor : AActor
{
	UPROPERTY(DefaultComponent)
	UNonExistentComponent Comp;
}
