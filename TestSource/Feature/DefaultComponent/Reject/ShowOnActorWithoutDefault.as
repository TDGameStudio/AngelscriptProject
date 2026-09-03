/**
 * ShowOnActor without DefaultComponent is rejected. ShowOnActor can only be used
 * on default components in actors; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.ShowOnActorWithoutDefault
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.ShowOnActorWithoutDefault
 * @Kind CompileReject
 * @Covers DefaultComponent.ShowOnActorWithoutDefault
 * @Inputs UPROPERTY(ShowOnActor) USceneComponent VisibleChild
 * @Return does not compile; "ShowOnActor can only be used on default components in actors"
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail: ShowOnActor without DefaultComponent.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
 * @Provenance CompileFixtureShouldFail module ASCoverageUClassDefaultComponent_ShowOnActorWithoutDefault.
 * @Provenance Expected diagnostic: "ShowOnActor can only be used on default components in actors".
 * @Provenance DiagnosticOnly. Do not add DefaultComponent.
 */

UCLASS()
class ACoverageUClassDefaultComponentShowOnActorWithoutDefault : AActor
{
	UPROPERTY(ShowOnActor)
	USceneComponent VisibleChild;
}
