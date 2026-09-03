/**
 * More than one RootComponent on an actor is rejected. An actor already has
 * a root. Do not drop RootComponent from Root2.
 *
 * @Theme Feature.Attach
 * @Subject Attach.Negative_MultipleRootComponents
 * @Harness CompileReject
 * @Tag Feature.Attach.Negative_MultipleRootComponents
 * @Kind CompileReject
 * @Covers Attach.Negative_MultipleRootComponents
 * @Inputs two UPROPERTY(DefaultComponent, RootComponent) scene components
 * @Return does not compile; diagnostic "Multiple RootComponents should fail"
 * @Provenance Theme: Feature.Attach. NegativeDiagnostic: more than one RootComponent on an actor.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_MultipleRootComponents.
 * @Provenance AssertFailsToCompile is currently #if 0 (#as-engine-behavior structural-validation-absent).
 * @Provenance Expected diagnostic: "Multiple RootComponents should fail".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

class ADefCompMultiRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root1;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root2;
}
