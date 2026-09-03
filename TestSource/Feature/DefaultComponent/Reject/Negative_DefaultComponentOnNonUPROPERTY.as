/**
 * DefaultComponent on a non-UPROPERTY field is rejected. The specifier belongs
 * on a UPROPERTY, not a default-assignment; this file is the illegal program.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Negative_DefaultComponentOnNonUPROPERTY
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.Negative_DefaultComponentOnNonUPROPERTY
 * @Kind CompileReject
 * @Covers DefaultComponent.Negative_DefaultComponentOnNonUPROPERTY
 * @Inputs USceneComponent Root; default Root = DefaultComponent
 * @Return does not compile; DefaultComponent on non-UPROPERTY field should fail
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_DefaultComponentOnNonUPROPERTY
 * @Provenance AssertFailsToCompile module DefCompNoUProp.
 * @Provenance Expected diagnostic: DefaultComponent on non-UPROPERTY field should fail.
 * @Provenance DiagnosticOnly. Isolation=none. Do not wrap Root in UPROPERTY.
 */

class ADefCompNoUPropActor : AActor
{
	USceneComponent Root;
	default Root = DefaultComponent;
}
