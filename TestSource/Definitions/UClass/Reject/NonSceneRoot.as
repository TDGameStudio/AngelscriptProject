/**
 * RootComponent on a non-scene actor component is rejected. RootComponent
 * requires a scene component type.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.NonSceneRoot
 * @Harness CompileReject
 * @Tag Definitions.UClass.NonSceneRoot
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs UPROPERTY(DefaultComponent, RootComponent) UCoverageUClassPlainRootLogicComponent RootLogic
 * @Return does not compile; diagnostic "has RootComponent set, but is not a type of scene component"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: RootComponent on a non-scene actor component.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: has RootComponent set, but is not a type of scene component.
 * @Provenance DiagnosticOnly. Do not change RootLogic to USceneComponent; that would make the program compile.
 */

UCLASS()
class UCoverageUClassPlainRootLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageUClassNonSceneRootActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UCoverageUClassPlainRootLogicComponent RootLogic;
}
