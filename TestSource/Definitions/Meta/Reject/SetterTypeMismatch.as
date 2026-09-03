/**
 * A BlueprintSetter argument type must match the property, so this program is
 * rejected. C++ compiles the module Tests.Compiler.PropertyCallbackValidation.SetterTypeMismatch
 * and expects the setter to take float while the written value is int. Do not
 * change SetTrackedValue to int.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.SetterTypeMismatch
 * @Harness CompileReject
 * @Tag Definitions.Meta.SetterTypeMismatch
 * @Provenance Theme: Definitions.Meta. Isolated compile-fail: BlueprintSetter type must match the property.
 * @Provenance C++: PropertyCallbackSignatureValidationReportsDiagnostics block 2.
 * @Provenance CSV Positive is wrong; C++ bCompileSucceeded false.
 * @Provenance Expected diagnostic: setter takes 'float' but the written value is 'int'.
 * @Provenance Isolate this failing program; do not change SetTrackedValue to int.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(BlueprintSetter=SetTrackedValue)
	int TrackedValue;

	/**
	 * The isolated failing program: SetTrackedValue takes float for an int property.
	 *
	 * @Kind CompileReject
	 * @Covers Meta.SetterTypeMismatch
	 * @Inputs a float Value
	 * @Return does not compile; setter takes 'float' but the written value is 'int'
	 * @Param Value the mismatched setter argument
	 */
	UFUNCTION()
	void SetTrackedValue(float Value)
	{
	}
}
