/**
 * DefaultComponent combined with OverrideComponent is rejected. The two
 * specifiers must not be used on the same property.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.OverrideAndDefault
 * @Harness CompileReject
 * @Tag Definitions.UClass.OverrideAndDefault
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs UPROPERTY(DefaultComponent, OverrideComponent=Root) USceneComponent Root
 * @Return does not compile; diagnostic "OverrideComponent and DefaultComponent should not be used simultaneously"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: DefaultComponent combined with OverrideComponent.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: OverrideComponent and DefaultComponent should not be used simultaneously.
 * @Provenance DiagnosticOnly. Do not drop either specifier; that would make the program compile.
 */

UCLASS()
class ACoverageUClassOverrideAndDefaultActor : AActor
{
	UPROPERTY(DefaultComponent, OverrideComponent=Root)
	USceneComponent Root;
}
