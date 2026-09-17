/**
 * @version v1
 * @summary C++ compiles this harness then binds a mismatched native. TriggerHealthChanged with a zero-arg native does not set bNativeFlag. This is a runtime signature mismatch, not a compile-fail.
 * @topic Feature
 */
/**
 * @version root
 * @summary C++ compiles this harness then binds a mismatched native. TriggerHealthChanged with a zero-arg native does not set bNativeFlag. This is a runtime signature mismatch, not a compile-fail.
 * @topic Baseline
 */
/**
 * A unicast that reports health and a label.
 *
 * @Covers Delegates.Execute
 * @Inputs NewHealth and Label
 * @Return nothing when executed
 */
delegate void FOnHealthChanged(int32 NewHealth, const FString&in Label);

UCLASS()
class ATestDelegateUnicastSigMismatch : AActor
{
	UPROPERTY()
	FOnHealthChanged OnHealthChanged;

	/**
	 * Executes OnHealthChanged when it is bound.
	 *
	 * @Covers Delegates.Execute
	 * @Param NewHealth the payload
	 * @Param Label the payload label
	 * @Inputs NewHealth and Label
	 * @Return nothing; unbound Execute is skipped
	 */
	UFUNCTION()
	void TriggerHealthChanged(int32 NewHealth, const FString&in Label)
	{
		if (OnHealthChanged.IsBound())
		{
			OnHealthChanged.Execute(NewHealth, Label);
		}
	}

	/**
	 * Observe that OnHealthChanged starts unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs this
	 * @Return true when OnHealthChanged is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool DefaultUnbound()
	{
		return !OnHealthChanged.IsBound();
	}

	/**
	 * Observe that triggering an unbound mismatch harness is a no-op.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs TriggerHealthChanged(91, "UnicastMismatch") then (0, "")
	 * @Return nothing
	 * @Boundary unbound trigger
	 */
	UFUNCTION()
	void UnboundTriggerIsNoOp()
	{
		TriggerHealthChanged(91, "UnicastMismatch");
		TriggerHealthChanged(0, "");
	}

	/**
	 * Observe that triggering this leaves Second unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs TriggerHealthChanged on this
	 * @Return true when both stay unbound
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TwoLocalsIndependent(ATestDelegateUnicastSigMismatch Second)
	{
		if (Second is null)
		{
			throw("SignatureMismatchDoesNotInvoke setup: required Second is null");
		}
		TriggerHealthChanged(91, "UnicastMismatch");
		if (OnHealthChanged.IsBound())
		{
			return false;
		}
		return !Second.OnHealthChanged.IsBound();
	}
}
/** @end */
