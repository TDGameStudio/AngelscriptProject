/**
 * Two RootComponent default components on one actor are rejected. An actor may
 * only name one root; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.DuplicateRoot
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.DuplicateRoot
 * @Kind CompileReject
 * @Covers DefaultComponent.DuplicateRoot
 * @Inputs two UPROPERTY(DefaultComponent, RootComponent) scene components
 * @Return does not compile; "is RootComponent, but the actor already has root component Root"
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail: two RootComponent default components.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
 * @Provenance CompileFixtureShouldFail module ASCoverageUClassDefaultComponent_DuplicateRoot.
 * @Provenance Expected diagnostic: "is RootComponent, but the actor already has root component Root".
 * @Provenance DiagnosticOnly. Do not drop the second RootComponent.
 */

UCLASS()
class ACoverageUClassDefaultComponentDuplicateRoot : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent OtherRoot;
}
