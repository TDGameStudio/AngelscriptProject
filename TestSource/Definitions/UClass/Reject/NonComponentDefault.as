/**
 * DefaultComponent on a plain UObject is rejected. The property type must
 * derive from UActorComponent.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.NonComponentDefault
 * @Harness CompileReject
 * @Tag Definitions.UClass.NonComponentDefault
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs UPROPERTY(DefaultComponent) UCoverageUClassPlainDefaultObject PlainObject
 * @Return does not compile; diagnostic "does not derive from UActorComponent"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: DefaultComponent on a plain UObject.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: does not derive from UActorComponent.
 * @Provenance DiagnosticOnly. Do not change PlainObject to a component type; that would make the program compile.
 */

UCLASS()
class UCoverageUClassPlainDefaultObject : UObject
{
}

UCLASS()
class ACoverageUClassNonComponentDefaultActor : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassPlainDefaultObject PlainObject;
}
