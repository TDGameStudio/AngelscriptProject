/**
 * RootComponent without DefaultComponent is rejected. RootComponent can only be
 * specified on DefaultComponents; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.RootWithoutDefault
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.RootWithoutDefault
 * @Kind CompileReject
 * @Covers DefaultComponent.RootWithoutDefault
 * @Inputs UPROPERTY(RootComponent) USceneComponent Root
 * @Return does not compile; "RootComponent can only be specified on DefaultComponents"
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail: RootComponent without DefaultComponent.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
 * @Provenance CompileFixtureShouldFail module ASCoverageUClassDefaultComponent_RootWithoutDefault.
 * @Provenance Expected diagnostic: "RootComponent can only be specified on DefaultComponents".
 * @Provenance DiagnosticOnly. Do not add DefaultComponent.
 */

UCLASS()
class ACoverageUClassDefaultComponentRootWithoutDefault : AActor
{
	UPROPERTY(RootComponent)
	USceneComponent Root;
}
