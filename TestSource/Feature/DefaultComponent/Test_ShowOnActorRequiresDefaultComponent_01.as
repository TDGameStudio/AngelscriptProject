// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptPreprocessorPropertyTests.cpp::ShowOnActorRequiresDefaultComponent block 1
// Expected diagnostic: ShowOnActor can only be used on default components in actors.
// DiagnosticOnly. Isolation=none.

UCLASS()
class AShowOnActorInvalidCarrier : AActor
{
	UPROPERTY(ShowOnActor)
	int PlainValue;
}
