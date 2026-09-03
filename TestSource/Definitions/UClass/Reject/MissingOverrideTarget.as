/**
 * OverrideComponent target missing on the base is rejected. The override name
 * must match a component on the base class.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.MissingOverrideTarget
 * @Harness CompileReject
 * @Tag Definitions.UClass.MissingOverrideTarget
 * @Kind CompileReject
 * @Covers UClass.OverrideComponent
 * @Inputs UPROPERTY(OverrideComponent=MissingScene) USceneComponent Replacement
 * @Return does not compile; diagnostic "could not find component MissingScene in base class to override"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent target missing on the base.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: could not find component MissingScene in base class to override.
 * @Provenance DiagnosticOnly. Do not retarget OverrideComponent to Root; that would make the program compile.
 */

UCLASS()
class ACoverageUClassMissingOverrideBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassMissingOverrideChildActor : ACoverageUClassMissingOverrideBaseActor
{
	UPROPERTY(OverrideComponent=MissingScene)
	USceneComponent Replacement;
}
