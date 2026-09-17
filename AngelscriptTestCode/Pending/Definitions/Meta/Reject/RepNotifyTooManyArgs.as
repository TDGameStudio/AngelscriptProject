/**
 * @version v1
 * @summary A ReplicatedUsing OnRep callback may not take two arguments, so this program is rejected. C++ compiles the module Tests.Compiler.PropertyCallbackValidation.RepNotifyTooManyArgs and expects "can not have more than 1.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A ReplicatedUsing OnRep callback may not take two arguments, so this program is rejected. C++ compiles the module Tests.Compiler.PropertyCallbackValidation.RepNotifyTooManyArgs and expects "can not have more than 1.
 * @topic Negative
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
/** @end */
