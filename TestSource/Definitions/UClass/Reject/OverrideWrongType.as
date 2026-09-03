/**
 * OverrideComponent type that does not inherit the base component is rejected.
 * The replacement must be a subclass of the overridden component type.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.OverrideWrongType
 * @Harness CompileReject
 * @Tag Definitions.UClass.OverrideWrongType
 * @Kind CompileReject
 * @Covers UClass.OverrideComponent
 * @Inputs UPROPERTY(OverrideComponent=Mesh) USceneComponent Replacement over UStaticMeshComponent Mesh
 * @Return does not compile; diagnostic "type does not inherit from the base class's"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent type does not inherit the base component.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: type does not inherit from the base class's.
 * @Provenance DiagnosticOnly. Do not replace USceneComponent with UStaticMeshComponent; that would make the program compile.
 */

UCLASS()
class ACoverageUClassOverrideWrongTypeBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent Mesh;
}

UCLASS()
class ACoverageUClassOverrideWrongTypeChildActor : ACoverageUClassOverrideWrongTypeBaseActor
{
	UPROPERTY(OverrideComponent=Mesh)
	USceneComponent Replacement;
}
