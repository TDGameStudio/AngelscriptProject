/**
 * RootComponent without DefaultComponent is rejected. RootComponent can only
 * be specified on DefaultComponents.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.RootWithoutDefault
 * @Harness CompileReject
 * @Tag Definitions.UClass.RootWithoutDefault
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs UPROPERTY(RootComponent) USceneComponent Root without DefaultComponent
 * @Return does not compile; diagnostic "RootComponent can only be specified on DefaultComponents"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: RootComponent without DefaultComponent.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: RootComponent can only be specified on DefaultComponents.
 * @Provenance DiagnosticOnly. Do not add DefaultComponent; that would make the program compile.
 */

UCLASS()
class ACoverageUClassRootWithoutDefaultActor : AActor
{
	UPROPERTY(RootComponent)
	USceneComponent Root;
}
