/**
 * DefaultComponent on a plain UObject is rejected. The property type must derive
 * from UActorComponent; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.NonComponentDefault
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.NonComponentDefault
 * @Kind CompileReject
 * @Covers DefaultComponent.NonComponentDefault
 * @Inputs UPROPERTY(DefaultComponent) UCoverageUClassDefaultComponentPlainObject PlainObject
 * @Return does not compile; "does not derive from UActorComponent"
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail: DefaultComponent on a plain UObject.
 * @Provenance C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
 * @Provenance CompileFixtureShouldFail module ASCoverageUClassDefaultComponent_NonComponentDefault.
 * @Provenance Expected diagnostic: "does not derive from UActorComponent".
 * @Provenance DiagnosticOnly. Do not change PlainObject to a component type.
 */

UCLASS()
class UCoverageUClassDefaultComponentPlainObject : UObject
{
}

UCLASS()
class ACoverageUClassDefaultComponentNonComponent : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassDefaultComponentPlainObject PlainObject;
}
