/**
 * A BlueprintGetter must be BlueprintPure, so this program is rejected. C++
 * compiles the module Tests.Compiler.PropertyCallbackValidation.GetterNeedsBlueprintPure
 * and expects "needs to be marked as BlueprintPure." Do not add BlueprintPure.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.GetterNeedsBlueprintPure
 * @Harness CompileReject
 * @Tag Definitions.Meta.GetterNeedsBlueprintPure
 * @Provenance Theme: Definitions.Meta. Isolated compile-fail: BlueprintGetter must be BlueprintPure.
 * @Provenance C++: PropertyCallbackSignatureValidationReportsDiagnostics block 3.
 * @Provenance CSV Positive is wrong; C++ bCompileSucceeded false.
 * @Provenance Expected diagnostic: "needs to be marked as BlueprintPure."
 * @Provenance Isolate this failing program; do not add BlueprintPure.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(BlueprintGetter=GetTrackedValue)
	int TrackedValue;

	/**
	 * The isolated failing program: GetTrackedValue is not BlueprintPure.
	 *
	 * @Kind CompileReject
	 * @Covers Meta.GetterNeedsBlueprintPure
	 * @Inputs none
	 * @Return does not compile; "needs to be marked as BlueprintPure."
	 */
	UFUNCTION()
	int GetTrackedValue() const
	{
		return TrackedValue;
	}
}
