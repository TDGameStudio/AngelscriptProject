// Theme: Gameplay.Net. Isolated compile-fail: unknown ReplicationCondition is a preprocessor error.
// C++: AngelscriptPreprocessorPropertyTests.cpp::UnknownReplicationConditionReportsDiagnostic
// Diagnostic: Unknown ReplicationCondition DefinitelyUnknown on property UBadPropertyCarrier::TrackedValue.
// CSV NegativeDiagnostic. Do not replace DefinitelyUnknown.

UCLASS()
class UBadPropertyCarrier : UObject
{
	UPROPERTY(Replicated, ReplicationCondition=DefinitelyUnknown)
	int TrackedValue;
}
