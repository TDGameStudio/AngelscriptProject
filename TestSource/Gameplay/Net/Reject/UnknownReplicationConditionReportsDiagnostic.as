/**
 * An unknown ReplicationCondition is a preprocessor error, so this program is
 * rejected. C++ expects the diagnostic "Unknown ReplicationCondition DefinitelyUnknown
 * on property UBadPropertyCarrier::TrackedValue." The illegal specifier must stay.
 *
 * @Theme Gameplay.Net
 * @Subject Net.UnknownReplicationConditionReportsDiagnostic
 * @Harness CompileReject
 * @Tag Gameplay.Net.UnknownReplicationConditionReportsDiagnostic
 * @Kind CompileReject
 * @Covers Net.UnknownReplicationConditionReportsDiagnostic
 * @Inputs UPROPERTY(Replicated, ReplicationCondition=DefinitelyUnknown) int TrackedValue
 * @Return does not compile; DefinitelyUnknown is not a ReplicationCondition
 * @Provenance Theme: Gameplay.Net. Isolated compile-fail: unknown ReplicationCondition is a preprocessor error.
 * @Provenance C++: AngelscriptPreprocessorPropertyTests.cpp::UnknownReplicationConditionReportsDiagnostic
 * @Provenance Diagnostic: Unknown ReplicationCondition DefinitelyUnknown on property UBadPropertyCarrier::TrackedValue.
 * @Provenance CSV NegativeDiagnostic. Do not replace DefinitelyUnknown.
 */

UCLASS()
class UBadPropertyCarrier : UObject
{
	UPROPERTY(Replicated, ReplicationCondition=DefinitelyUnknown)
	int TrackedValue;
}
