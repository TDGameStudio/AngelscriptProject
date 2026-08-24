// Theme: Definitions.Meta. Isolated compile-fail: ReplicatedUsing OnRep may not take two args.
// C++: PropertyCallbackSignatureValidationReportsDiagnostics block 1.
// CSV Positive is wrong; C++ bCompileSucceeded false.
// Expected diagnostic: "can not have more than 1 argument."
// Isolate this failing program; do not add a one-arg OnRep that would compile it away.
// DiagnosticOnly.

UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(ReplicatedUsing=OnRep_TrackedValue)
	int TrackedValue;

	UFUNCTION()
	void OnRep_TrackedValue(int OldValue, int NewValue)
	{
	}
}
