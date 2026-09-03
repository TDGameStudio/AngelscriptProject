/**
 * ShowOnActor without DefaultComponent is rejected. ShowOnActor can only be
 * used on default components in actors.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ShowOnActorWithoutDefault
 * @Harness CompileReject
 * @Tag Definitions.UClass.ShowOnActorWithoutDefault
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs UPROPERTY(ShowOnActor) USceneComponent VisibleChild without DefaultComponent
 * @Return does not compile; diagnostic "ShowOnActor can only be used on default components in actors"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: ShowOnActor without DefaultComponent.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: ShowOnActor can only be used on default components in actors.
 * @Provenance DiagnosticOnly. Do not add DefaultComponent; that would make the program compile.
 */

UCLASS()
class ACoverageUClassShowOnActorWithoutDefaultActor : AActor
{
	UPROPERTY(ShowOnActor)
	USceneComponent VisibleChild;
}
