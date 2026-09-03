/**
 * Attach to a component that does not exist is rejected. The named Attach
 * target must be a declared default component; this file is the illegal program.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Negative_AttachToNonExistent
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.Negative_AttachToNonExistent
 * @Kind CompileReject
 * @Covers DefaultComponent.Negative_AttachToNonExistent
 * @Inputs UPROPERTY(DefaultComponent, Attach = NonExistent) USceneComponent Child
 * @Return does not compile; Attach to non-existent component should fail
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_AttachToNonExistent
 * @Provenance AssertFailsToCompile module DefCompBadAttach.
 * @Provenance Expected diagnostic: Attach to non-existent component should fail.
 * @Provenance DiagnosticOnly. Isolation=none. Do not declare NonExistent.
 */

class ADefCompBadAttachActor : AActor
{
	UPROPERTY(DefaultComponent, Attach = NonExistent)
	USceneComponent Child;
}
