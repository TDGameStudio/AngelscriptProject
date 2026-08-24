// Theme: Feature.Delegates. C++ compiles this harness then binds a mismatched native.
// CSV SourceShape NegativeDiagnostic is the runtime "Signature mismatch" path, not compile-fail.
// C++: AngelscriptDelegateTests.cpp::SignatureMismatchDoesNotInvoke (unicast)
// sha256= from theme-refs TS-FEAT-0202; lines 279-297.
// Oracle: script compiles; TriggerHealthChanged with a zero-arg native does not set bNativeFlag.
// Extra: local construct is unbound so TriggerHealthChanged is a no-op; empty Label.
// FixtureIsolated. Native mismatch bind is runner-owned.

delegate void FOnHealthChanged(int32 NewHealth, const FString& Label);

UCLASS()
class ATestDelegateUnicastSigMismatch : AActor
{
	UPROPERTY()
	FOnHealthChanged OnHealthChanged;

	UFUNCTION()
	void TriggerHealthChanged(int32 NewHealth, const FString& Label)
	{
		if (OnHealthChanged.IsBound())
		{
			OnHealthChanged.Execute(NewHealth, Label);
		}
	}
}

bool Observe_UnicastSigMismatch_DefaultUnbound(ATestDelegateUnicastSigMismatch Actor)
{
	if (Actor is null)
	{
		throw("Test_SignatureMismatchDoesNotInvoke setup: required Actor is null");
	}
	return !Actor.OnHealthChanged.IsBound();
}

void Observe_UnicastSigMismatch_UnboundTriggerIsNoOp(ATestDelegateUnicastSigMismatch Actor)
{
	if (Actor is null)
	{
		throw("Test_SignatureMismatchDoesNotInvoke setup: required Actor is null");
	}
	Actor.TriggerHealthChanged(91, "UnicastMismatch");
	Actor.TriggerHealthChanged(0, "");
}

bool Observe_UnicastSigMismatch_TwoLocalsIndependent(ATestDelegateUnicastSigMismatch First, ATestDelegateUnicastSigMismatch Second)
{
	if (First is null)
	{
		throw("Test_SignatureMismatchDoesNotInvoke setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SignatureMismatchDoesNotInvoke setup: required Second is null");
	}
	First.TriggerHealthChanged(91, "UnicastMismatch");
	return !First.OnHealthChanged.IsBound() && !Second.OnHealthChanged.IsBound();
}
