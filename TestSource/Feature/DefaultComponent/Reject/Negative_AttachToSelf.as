/**
 * Attach to self is rejected. A DefaultComponent may not name itself as its
 * Attach parent; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Negative_AttachToSelf
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.Negative_AttachToSelf
 * @Kind CompileReject
 * @Covers DefaultComponent.Negative_AttachToSelf
 * @Inputs UPROPERTY(DefaultComponent, Attach = Myself) USceneComponent Myself
 * @Return does not compile; DefaultComponent attaching to self should fail
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_AttachToSelf
 * @Provenance Expected diagnostic: DefaultComponent attaching to self should fail.
 * @Provenance C++ AssertFailsToCompile is currently #if 0 (#as-engine-behavior).
 * @Provenance DiagnosticOnly. Isolation=none. Do not rename Myself.
 */

class ADefCompSelfActor : AActor
{
	UPROPERTY(DefaultComponent, Attach = Myself)
	USceneComponent Myself;
}
