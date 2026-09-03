/**
 * Circular attachment is rejected. Two DefaultComponents may not Attach to each
 * other; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Negative_CircularAttach
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.Negative_CircularAttach
 * @Kind CompileReject
 * @Covers DefaultComponent.Negative_CircularAttach
 * @Inputs CompA Attach = CompB and CompB Attach = CompA
 * @Return does not compile; Circular attachment should fail
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_CircularAttach
 * @Provenance Expected diagnostic: Circular attachment should fail.
 * @Provenance C++ AssertFailsToCompile is currently #if 0 (#as-engine-behavior).
 * @Provenance DiagnosticOnly. Isolation=none. Do not break the CompA/CompB cycle.
 */

class ADefCompCircularActor : AActor
{
	UPROPERTY(DefaultComponent, Attach = CompB)
	USceneComponent CompA;

	UPROPERTY(DefaultComponent, Attach = CompA)
	USceneComponent CompB;
}
