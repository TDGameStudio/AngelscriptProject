// Theme: Definitions.Meta. Isolated compile-fail: BlueprintSetter type must match the property.
// C++: PropertyCallbackSignatureValidationReportsDiagnostics block 2.
// CSV Positive is wrong; C++ bCompileSucceeded false.
// Expected diagnostic: setter takes 'float' but the written value is 'int'.
// Isolate this failing program; do not change SetTrackedValue to int.
// DiagnosticOnly.

UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(BlueprintSetter=SetTrackedValue)
	int TrackedValue;

	UFUNCTION()
	void SetTrackedValue(float Value)
	{
	}
}
