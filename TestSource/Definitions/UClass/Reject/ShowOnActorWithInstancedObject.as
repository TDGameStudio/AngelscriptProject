/**
 * DefaultComponent plus ShowOnActor on a plain UObject is rejected. The
 * property type must derive from UActorComponent.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.ShowOnActorWithInstancedObject
 * @Harness CompileReject
 * @Tag Definitions.UClass.ShowOnActorWithInstancedObject
 * @Kind CompileReject
 * @Covers UClass.DefaultComponent
 * @Inputs UPROPERTY(DefaultComponent, ShowOnActor) UCoverageUClassShowOnActorPlainObject PlainObject
 * @Return does not compile; diagnostic "does not derive from UActorComponent"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: DefaultComponent+ShowOnActor on a plain UObject.
 * @Provenance C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
 * @Provenance Expected diagnostic: does not derive from UActorComponent.
 * @Provenance DiagnosticOnly. Do not change PlainObject to a component type; that would make the program compile.
 */

UCLASS()
class UCoverageUClassShowOnActorPlainObject : UObject
{
}

UCLASS()
class ACoverageUClassShowOnActorInstancedObjectActor : AActor
{
	UPROPERTY(DefaultComponent, ShowOnActor)
	UCoverageUClassShowOnActorPlainObject PlainObject;
}
