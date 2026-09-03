/**
 * Attach without DefaultComponent is rejected. Attachments can only be
 * specified on DefaultComponents.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.AttachWithoutDefault
 * @Harness CompileReject
 * @Tag Definitions.UClass.AttachWithoutDefault
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs UPROPERTY(Attach=Root) USceneComponent Child without DefaultComponent
 * @Return does not compile; diagnostic "Attachments can only be specified on DefaultComponents"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: Attach without DefaultComponent.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Attachments can only be specified on DefaultComponents.
 * @Provenance DiagnosticOnly. Do not add DefaultComponent; that would make the program compile.
 */

UCLASS()
class ACoverageUClassAttachWithoutDefaultActor : AActor
{
	UPROPERTY(Attach=Root)
	USceneComponent Child;
}
