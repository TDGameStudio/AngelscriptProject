/**
 * Attach on a non-scene actor component is rejected. Attach requires a scene
 * component type.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.NonSceneAttach
 * @Harness CompileReject
 * @Tag Definitions.UClass.NonSceneAttach
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs UPROPERTY(DefaultComponent, Attach=Root) UCoverageUClassPlainAttachLogicComponent Logic
 * @Return does not compile; diagnostic "has a component attach set, but is not a type of scene component"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: Attach on a non-scene actor component.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: has a component attach set, but is not a type of scene component.
 * @Provenance DiagnosticOnly. Do not change Logic to USceneComponent; that would make the program compile.
 */

UCLASS()
class UCoverageUClassPlainAttachLogicComponent : UActorComponent
{
}

UCLASS()
class ACoverageUClassNonSceneAttachActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	UCoverageUClassPlainAttachLogicComponent Logic;
}
