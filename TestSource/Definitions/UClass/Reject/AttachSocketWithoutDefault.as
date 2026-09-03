/**
 * AttachSocket without DefaultComponent is rejected. Attachments can only be
 * specified on DefaultComponents.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.AttachSocketWithoutDefault
 * @Harness CompileReject
 * @Tag Definitions.UClass.AttachSocketWithoutDefault
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs UPROPERTY(AttachSocket="LooseSocket") USceneComponent Child without DefaultComponent
 * @Return does not compile; diagnostic "Attachments can only be specified on DefaultComponents"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: AttachSocket without DefaultComponent.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Attachments can only be specified on DefaultComponents.
 * @Provenance DiagnosticOnly. Do not add DefaultComponent; that would make the program compile.
 */

UCLASS()
class ACoverageUClassAttachSocketWithoutDefaultActor : AActor
{
	UPROPERTY(AttachSocket="LooseSocket")
	USceneComponent Child;
}
