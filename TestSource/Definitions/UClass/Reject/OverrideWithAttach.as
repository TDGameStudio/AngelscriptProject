/**
 * OverrideComponent also marked Attach is rejected. Attachments can only be
 * specified on DefaultComponents.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.OverrideWithAttach
 * @Harness CompileReject
 * @Tag Definitions.UClass.OverrideWithAttach
 * @Kind CompileReject
 * @Covers UClass.OverrideComponent
 * @Inputs UPROPERTY(OverrideComponent=Child, Attach=Root) USceneComponent Replacement
 * @Return does not compile; diagnostic "Attachments can only be specified on DefaultComponents"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent also marked Attach.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Attachments can only be specified on DefaultComponents.
 * @Provenance DiagnosticOnly. Do not drop Attach from the override; that would make the program compile.
 */

UCLASS()
class ACoverageUClassOverrideWithAttachBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child;
}

UCLASS()
class ACoverageUClassOverrideWithAttachChildActor : ACoverageUClassOverrideWithAttachBaseActor
{
	UPROPERTY(OverrideComponent=Child, Attach=Root)
	USceneComponent Replacement;
}
