/**
 * Unicast Execute of a bound native callback. Script only Executes if IsBound.
 * The native bind is runner-owned. An unbound TriggerHealthChanged is a no-op.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.ExecuteWithBoundNativeCallback
 * @Harness UClass
 * @Tag Feature.Delegates.ExecuteWithBoundNativeCallback
 * @Provenance Theme: Feature.Delegates. WorldStory unicast Execute of a bound native callback.
 * @Provenance C++: AngelscriptDelegateTests.cpp::ExecuteWithBoundNativeCallback
 * @Provenance sha256=f12ab9ff04bbb79c0970beb841e6ec15da627391c89d7bc3004bf0ddc029b04a; lines 60-78.
 * @Provenance Oracle: C++ binds SetIntStringFromDelegate then TriggerHealthChanged(77, "Unicast")
 * @Provenance yields NativeReceiver NameCounts["Unicast"] == 77.
 * @Provenance Extra: local construct is unbound so TriggerHealthChanged is a no-op; empty Label.
 * @Provenance FixtureIsolated. Native bind is runner-owned; script only Executes if IsBound.
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
class ATestDelegateUnicast : AActor
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
	 * Observe that triggering an unbound delegate is a no-op.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs TriggerHealthChanged(77, "Unicast") then (0, "")
	 * @Return nothing
	 * @Boundary unbound trigger
	 */
	UFUNCTION()
	void UnboundTriggerIsNoOp()
	{
		TriggerHealthChanged(77, "Unicast");
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
	bool TwoLocalsIndependent(ATestDelegateUnicast Second)
	{
		if (Second is null)
		{
			throw("ExecuteWithBoundNativeCallback setup: required Second is null");
		}
		TriggerHealthChanged(77, "Unicast");
		if (OnHealthChanged.IsBound())
		{
			return false;
		}
		return !Second.OnHealthChanged.IsBound();
	}
}
