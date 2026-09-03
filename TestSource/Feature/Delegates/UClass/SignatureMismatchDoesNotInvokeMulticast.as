/**
 * C++ compiles this multicast harness then binds a mismatched native.
 * TriggerDamaged with a zero-arg native does not set bNativeFlag. This is a
 * runtime signature mismatch, not a compile-fail.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.SignatureMismatchDoesNotInvokeMulticast
 * @Harness UClass
 * @Tag Feature.Delegates.SignatureMismatchDoesNotInvokeMulticast
 * @Provenance Theme: Feature.Delegates. C++ compiles this harness then binds a mismatched native.
 * @Provenance CSV SourceShape NegativeDiagnostic is the runtime "Signature mismatch" path, not compile-fail.
 * @Provenance C++: AngelscriptDelegateTests.cpp::SignatureMismatchDoesNotInvoke (multicast)
 * @Provenance sha256 from theme-refs TS-FEAT-0209; lines 754-769.
 * @Provenance Oracle: script compiles; TriggerDamaged with a zero-arg native does not set bNativeFlag.
 * @Provenance Extra: local construct is unbound so Broadcast is a no-op; empty Label.
 * @Provenance FixtureIsolated. Native mismatch bind is runner-owned.
 */

/**
 * A multicast event that reports health and a label.
 *
 * @Covers Delegates.Broadcast
 * @Inputs NewHealth and Label
 * @Return nothing when broadcast
 */
event void FOnDamaged(int32 NewHealth, const FString&in Label);

UCLASS()
class ATestDelegateMulticastSigMismatch : AActor
{
	UPROPERTY()
	FOnDamaged OnDamaged;

	/**
	 * Broadcasts OnDamaged.
	 *
	 * @Covers Delegates.Broadcast
	 * @Param NewHealth the payload
	 * @Param Label the payload label
	 * @Inputs NewHealth and Label
	 * @Return nothing
	 */
	UFUNCTION()
	void TriggerDamaged(int32 NewHealth, const FString&in Label)
	{
		OnDamaged.Broadcast(NewHealth, Label);
	}

	/**
	 * Observe that OnDamaged starts unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs this
	 * @Return true when OnDamaged is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool DefaultUnbound()
	{
		return !OnDamaged.IsBound();
	}

	/**
	 * Observe that broadcasting on an unbound mismatch harness is a no-op.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs TriggerDamaged(0, "") then (91, "MulticastMismatch")
	 * @Return nothing
	 * @Boundary unbound broadcast
	 */
	UFUNCTION()
	void UnboundBroadcastIsNoOp()
	{
		TriggerDamaged(0, "");
		TriggerDamaged(91, "MulticastMismatch");
	}

	/**
	 * Observe that broadcasting on this leaves Second unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs TriggerDamaged on this
	 * @Return true when both stay unbound
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TwoLocalsIndependent(ATestDelegateMulticastSigMismatch Second)
	{
		if (Second is null)
		{
			throw("SignatureMismatchDoesNotInvokeMulticast setup: required Second is null");
		}
		TriggerDamaged(91, "MulticastMismatch");
		if (OnDamaged.IsBound())
		{
			return false;
		}
		return !Second.OnDamaged.IsBound();
	}
}
