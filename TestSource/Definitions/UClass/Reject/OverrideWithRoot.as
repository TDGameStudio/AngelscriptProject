/**
 * OverrideComponent also marked RootComponent is rejected. RootComponent can
 * only be specified on DefaultComponents.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.OverrideWithRoot
 * @Harness CompileReject
 * @Tag Definitions.UClass.OverrideWithRoot
 * @Kind CompileReject
 * @Covers UClass.OverrideComponent
 * @Inputs UPROPERTY(OverrideComponent=Root, RootComponent) USceneComponent Replacement
 * @Return does not compile; diagnostic "RootComponent can only be specified on DefaultComponents"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent also marked RootComponent.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: RootComponent can only be specified on DefaultComponents.
 * @Provenance DiagnosticOnly. Do not drop RootComponent from the override; that would make the program compile.
 */

UCLASS()
class ACoverageUClassOverrideWithRootBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassOverrideWithRootChildActor : ACoverageUClassOverrideWithRootBaseActor
{
	UPROPERTY(OverrideComponent=Root, RootComponent)
	USceneComponent Replacement;
}
