/**
 * OverrideComponent on a plain UObject is rejected. The replacement type must
 * be a component.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.NonComponentOverride
 * @Harness CompileReject
 * @Tag Definitions.UClass.NonComponentOverride
 * @Kind CompileReject
 * @Covers UClass.OverrideComponent
 * @Inputs UPROPERTY(OverrideComponent=Root) UCoverageUClassPlainOverrideObject Replacement
 * @Return does not compile; diagnostic "was marked as OverrideComponent, but is not a type of component"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent on a plain UObject.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: was marked as OverrideComponent, but is not a type of component.
 * @Provenance DiagnosticOnly. Do not change Replacement to a component type; that would make the program compile.
 */

UCLASS()
class UCoverageUClassPlainOverrideObject : UObject
{
}

UCLASS()
class ACoverageUClassNonComponentOverrideBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassNonComponentOverrideChildActor : ACoverageUClassNonComponentOverrideBaseActor
{
	UPROPERTY(OverrideComponent=Root)
	UCoverageUClassPlainOverrideObject Replacement;
}
