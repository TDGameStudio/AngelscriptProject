/**
 * DefaultComponent in a non-Actor class is rejected. The specifier is only valid
 * on actor properties; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.Negative_InNonActorClass
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.Negative_InNonActorClass
 * @Kind CompileReject
 * @Covers DefaultComponent.Negative_InNonActorClass
 * @Inputs struct FDefCompStruct with UPROPERTY(DefaultComponent) USceneComponent Root
 * @Return does not compile; DefaultComponent in non-Actor class should fail
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptSyntaxDefaultComponentTests.cpp::Negative_InNonActorClass
 * @Provenance Expected diagnostic: DefaultComponent in non-Actor class should fail.
 * @Provenance C++ AssertFailsToCompile is currently #if 0 (#as-engine-behavior).
 * @Provenance DiagnosticOnly. Isolation=none. Do not change FDefCompStruct to an actor.
 */

struct FDefCompStruct
{
	UPROPERTY(DefaultComponent)
	USceneComponent Root;
}
