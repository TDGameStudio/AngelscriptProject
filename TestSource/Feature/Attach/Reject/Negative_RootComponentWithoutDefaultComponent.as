/**
 * RootComponent without DefaultComponent is rejected. RootComponent can only
 * be specified on DefaultComponents. Do not add DefaultComponent.
 *
 * @Theme Feature.Attach
 * @Subject Attach.Negative_RootComponentWithoutDefaultComponent
 * @Harness CompileReject
 * @Tag Feature.Attach.Negative_RootComponentWithoutDefaultComponent
 * @Kind CompileReject
 * @Covers Attach.Negative_RootComponentWithoutDefaultComponent
 * @Inputs UPROPERTY(RootComponent) USceneComponent Root without DefaultComponent
 * @Return does not compile; diagnostic "RootComponent without DefaultComponent should fail"
 * @Provenance Theme: Feature.Attach. NegativeDiagnostic: RootComponent without DefaultComponent.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_RootComponentWithoutDefaultComponent.
 * @Provenance AssertFailsToCompile is currently #if 0 (#as-engine-behavior structural-validation-absent).
 * @Provenance Expected diagnostic: "RootComponent without DefaultComponent should fail".
 * @Provenance Isolate the failing program. DiagnosticOnly.
 */

class ADefCompRootOnlyActor : AActor
{
	UPROPERTY(RootComponent)
	USceneComponent Root;
}
