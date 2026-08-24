// Theme: Feature.Delegates. WorldStory unicast Execute of a bound native callback.
// C++: AngelscriptDelegateTests.cpp::ExecuteWithBoundNativeCallback
// sha256=f12ab9ff04bbb79c0970beb841e6ec15da627391c89d7bc3004bf0ddc029b04a; lines 60-78.
// Oracle: C++ binds SetIntStringFromDelegate then TriggerHealthChanged(77, "Unicast")
// yields NativeReceiver NameCounts["Unicast"] == 77.
// Extra: local construct is unbound so TriggerHealthChanged is a no-op; empty Label.
// FixtureIsolated. Native bind is runner-owned; script only Executes if IsBound.

delegate void FOnHealthChanged(int32 NewHealth, const FString& Label);

UCLASS()
class ATestDelegateUnicast : AActor
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

bool Observe_Unicast_DefaultUnbound(ATestDelegateUnicast Actor)
{
	if (Actor is null)
	{
		throw("Test_ExecuteWithBoundNativeCallback setup: required Actor is null");
	}
	return !Actor.OnHealthChanged.IsBound();
}

void Observe_Unicast_UnboundTriggerIsNoOp(ATestDelegateUnicast Actor)
{
	if (Actor is null)
	{
		throw("Test_ExecuteWithBoundNativeCallback setup: required Actor is null");
	}
	Actor.TriggerHealthChanged(77, "Unicast");
	Actor.TriggerHealthChanged(0, "");
}

bool Observe_Unicast_TwoLocalsIndependent(ATestDelegateUnicast First, ATestDelegateUnicast Second)
{
	if (First is null)
	{
		throw("Test_ExecuteWithBoundNativeCallback setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ExecuteWithBoundNativeCallback setup: required Second is null");
	}
	First.TriggerHealthChanged(77, "Unicast");
	return !First.OnHealthChanged.IsBound() && !Second.OnHealthChanged.IsBound();
}
