/**
 * DefaultComponent that uses an Abstract scene class is rejected. Abstract
 * component classes cannot be added as default components.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.AbstractDefaultComponent
 * @Harness CompileReject
 * @Tag Definitions.UClass.AbstractDefaultComponent
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs UPROPERTY(DefaultComponent) UCoverageUClassAbstractDefaultSceneComponent AbstractComponent
 * @Return does not compile; diagnostic "was marked as DefaultComponent, but the component class is abstract and cannot be added"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: DefaultComponent uses an Abstract scene class.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: was marked as DefaultComponent, but the component class is abstract and cannot be added.
 * @Provenance DiagnosticOnly. Do not drop Abstract; that would make the program compile.
 */

UCLASS(Abstract)
class UCoverageUClassAbstractDefaultSceneComponent : USceneComponent
{
}

UCLASS()
class ACoverageUClassAbstractDefaultComponentActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassAbstractDefaultSceneComponent AbstractComponent;
}
