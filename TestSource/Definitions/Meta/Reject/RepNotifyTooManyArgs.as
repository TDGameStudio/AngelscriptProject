/**
 * A ReplicatedUsing OnRep callback may not take two arguments, so this program is
 * rejected. C++ compiles the module Tests.Compiler.PropertyCallbackValidation.RepNotifyTooManyArgs
 * and expects "can not have more than 1 argument." Do not add a one-arg OnRep
 * that would compile it away.
 *
 * @Theme Definitions.Meta
 * @Subject Meta.RepNotifyTooManyArgs
 * @Harness CompileReject
 * @Tag Definitions.Meta.RepNotifyTooManyArgs
 * @Provenance Theme: Definitions.Meta. Isolated compile-fail: ReplicatedUsing OnRep may not take two args.
 * @Provenance C++: PropertyCallbackSignatureValidationReportsDiagnostics block 1.
 * @Provenance CSV Positive is wrong; C++ bCompileSucceeded false.
 * @Provenance Expected diagnostic: "can not have more than 1 argument."
 * @Provenance Isolate this failing program; do not add a one-arg OnRep that would compile it away.
 * @Provenance DiagnosticOnly.
 */

UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(ReplicatedUsing=OnRep_TrackedValue)
	int TrackedValue;

	/**
	 * The isolated failing program: OnRep_TrackedValue takes two arguments.
	 *
	 * @Kind CompileReject
	 * @Covers Meta.RepNotifyTooManyArgs
	 * @Inputs OldValue and NewValue
	 * @Return does not compile; "can not have more than 1 argument."
	 * @Param OldValue the previous replicated value
	 * @Param NewValue the new replicated value
	 */
	UFUNCTION()
	void OnRep_TrackedValue(int OldValue, int NewValue)
	{
	}
}
