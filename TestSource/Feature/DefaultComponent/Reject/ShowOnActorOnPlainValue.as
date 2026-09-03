/**
 * ShowOnActor on a non-component property is rejected. ShowOnActor can only be
 * used on default components in actors; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.ShowOnActorOnPlainValue
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.ShowOnActorOnPlainValue
 * @Kind CompileReject
 * @Covers DefaultComponent.ShowOnActorOnPlainValue
 * @Inputs UPROPERTY(ShowOnActor) int PlainValue
 * @Return does not compile; ShowOnActor can only be used on default components in actors
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptPreprocessorPropertyTests.cpp::ShowOnActorRequiresDefaultComponent block 1
 * @Provenance Fixture Tests/Preprocessor/Components/ShowOnActorRequiresDefaultComponent_Invalid.as.
 * @Provenance Expected diagnostic: ShowOnActor can only be used on default components in actors.
 * @Provenance DiagnosticOnly. Isolation=none. Do not add DefaultComponent or change PlainValue.
 */

UCLASS()
class AShowOnActorInvalidCarrier : AActor
{
	UPROPERTY(ShowOnActor)
	int PlainValue;
}
