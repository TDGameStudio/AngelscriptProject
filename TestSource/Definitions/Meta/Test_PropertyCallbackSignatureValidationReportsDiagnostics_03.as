// Theme: Definitions.Meta. Isolated compile-fail: BlueprintGetter must be BlueprintPure.
// C++: PropertyCallbackSignatureValidationReportsDiagnostics block 3.
// CSV Positive is wrong; C++ bCompileSucceeded false.
// Expected diagnostic: "needs to be marked as BlueprintPure."
// Isolate this failing program; do not add BlueprintPure.
// DiagnosticOnly.

UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(BlueprintGetter=GetTrackedValue)
	int TrackedValue;

	UFUNCTION()
	int GetTrackedValue() const
	{
		return TrackedValue;
	}
}
