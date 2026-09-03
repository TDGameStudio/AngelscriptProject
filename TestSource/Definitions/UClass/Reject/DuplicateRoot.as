/**
 * Two RootComponent default components are rejected. An actor already has
 * root component Root.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.DuplicateRoot
 * @Harness CompileReject
 * @Tag Definitions.UClass.DuplicateRoot
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs two UPROPERTY(DefaultComponent, RootComponent) scene components
 * @Return does not compile; diagnostic "is RootComponent, but the actor already has root component Root"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: two RootComponent default components.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: is RootComponent, but the actor already has root component Root.
 * @Provenance DiagnosticOnly. Do not drop RootComponent from OtherRoot; that would make the program compile.
 */

UCLASS()
class ACoverageUClassDuplicateRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent OtherRoot;
}
