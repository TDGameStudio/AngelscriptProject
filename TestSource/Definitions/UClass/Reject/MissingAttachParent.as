/**
 * Attach parent name that does not exist is rejected. The parent must name a
 * DefaultComponent on the same actor.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.MissingAttachParent
 * @Harness CompileReject
 * @Tag Definitions.UClass.MissingAttachParent
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs UPROPERTY(DefaultComponent, Attach=MissingParent) USceneComponent Child
 * @Return does not compile; diagnostic "Attach parent MissingParent does not exist for DefaultComponent Child"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: Attach parent name does not exist.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: Attach parent MissingParent does not exist for DefaultComponent Child.
 * @Provenance DiagnosticOnly. Do not retarget Attach to Root; that would make the program compile.
 */

UCLASS()
class ACoverageUClassMissingAttachParentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=MissingParent)
	USceneComponent Child;
}
