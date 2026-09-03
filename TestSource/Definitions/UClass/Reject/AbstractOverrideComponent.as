/**
 * OverrideComponent that uses an Abstract scene class is rejected. Abstract
 * component classes cannot be used as overrides.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.AbstractOverrideComponent
 * @Harness CompileReject
 * @Tag Definitions.UClass.AbstractOverrideComponent
 * @Kind CompileReject
 * @Covers UClass.OverrideComponent
 * @Inputs UPROPERTY(OverrideComponent=Root) UCoverageUClassAbstractOverrideSceneComponent Replacement
 * @Return does not compile; diagnostic "was marked as OverrideComponent, but the component class is abstract and cannot be used"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent uses an Abstract scene class.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: was marked as OverrideComponent, but the component class is abstract and cannot be used.
 * @Provenance DiagnosticOnly. Do not drop Abstract; that would make the program compile.
 */

UCLASS(Abstract)
class UCoverageUClassAbstractOverrideSceneComponent : USceneComponent
{
}

UCLASS()
class ACoverageUClassAbstractOverrideBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassAbstractOverrideChildActor : ACoverageUClassAbstractOverrideBaseActor
{
	UPROPERTY(OverrideComponent=Root)
	UCoverageUClassAbstractOverrideSceneComponent Replacement;
}
