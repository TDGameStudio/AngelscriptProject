// Theme: Feature.Delegates. C++ compiles this harness then binds a mismatched native.
// CSV SourceShape NegativeDiagnostic is the runtime "Signature mismatch" path, not compile-fail.
// C++: AngelscriptDelegateTests.cpp::SignatureMismatchDoesNotInvoke (multicast)
// sha256 from theme-refs TS-FEAT-0209; lines 754-769.
// Oracle: script compiles; TriggerDamaged with a zero-arg native does not set bNativeFlag.
// Extra: local construct is unbound so Broadcast is a no-op; empty Label.
// FixtureIsolated. Native mismatch bind is runner-owned.

event void FOnDamaged(int32 NewHealth, const FString& Label);

UCLASS()
class ATestDelegateMulticastSigMismatch : AActor
{
	UPROPERTY()
	FOnDamaged OnDamaged;

	UFUNCTION()
	void TriggerDamaged(int32 NewHealth, const FString& Label)
	{
		OnDamaged.Broadcast(NewHealth, Label);
	}
}

bool Observe_MulticastSigMismatch_DefaultUnbound(ATestDelegateMulticastSigMismatch Actor)
{
	if (Actor is null)
	{
		throw("Test_SignatureMismatchDoesNotInvoke_R02259 setup: required Actor is null");
	}
	return !Actor.OnDamaged.IsBound();
}

void Observe_MulticastSigMismatch_UnboundBroadcastIsNoOp(ATestDelegateMulticastSigMismatch Actor)
{
	if (Actor is null)
	{
		throw("Test_SignatureMismatchDoesNotInvoke_R02259 setup: required Actor is null");
	}
	Actor.TriggerDamaged(0, "");
	Actor.TriggerDamaged(91, "MulticastMismatch");
}

bool Observe_MulticastSigMismatch_TwoLocalsIndependent(ATestDelegateMulticastSigMismatch First, ATestDelegateMulticastSigMismatch Second)
{
	if (First is null)
	{
		throw("Test_SignatureMismatchDoesNotInvoke_R02259 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SignatureMismatchDoesNotInvoke_R02259 setup: required Second is null");
	}
	First.TriggerDamaged(91, "MulticastMismatch");
	return !First.OnDamaged.IsBound() && !Second.OnDamaged.IsBound();
}
