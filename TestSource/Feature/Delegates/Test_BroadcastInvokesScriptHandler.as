// Theme: Feature.Delegates. WorldStory multicast AddUFunction; C++ ProcessDelegate after BeginPlay.
// C++: AngelscriptDelegateTests.cpp::BroadcastInvokesScriptHandler
// sha256 from theme-refs TS-FEAT-0203; lines 372-396.
// Oracle: EventTriggerCount > 0 after C++ multicast ProcessDelegate(33, "Multicast").
// Extra: local construct EventTriggerCount 0 and unbound; HandleDamaged(0, "") is the zero write.
// FixtureIsolated. BeginPlay binds n"HandleDamaged"; C++ owns the later Broadcast.

event void FOnDamaged(int32 NewHealth, const FString& Label);

UCLASS()
class ATestDelegateMulticast : AActor
{
	UPROPERTY()
	FOnDamaged OnDamaged;

	UPROPERTY()
	int EventTriggerCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnDamaged.AddUFunction(this, n"HandleDamaged");
	}

	UFUNCTION()
	void HandleDamaged(int32 NewHealth, const FString& Label)
	{
		EventTriggerCount += 1;
	}
}

int Observe_BroadcastInvokesScriptHandler_DefaultEmpty(ATestDelegateMulticast Actor)
{
	if (Actor is null)
	{
		throw("Test_BroadcastInvokesScriptHandler setup: required Actor is null");
	}
	return Actor.EventTriggerCount;
}

int Observe_BroadcastInvokesScriptHandler_ZeroHealthWrite(ATestDelegateMulticast Actor)
{
	if (Actor is null)
	{
		throw("Test_BroadcastInvokesScriptHandler setup: required Actor is null");
	}
	Actor.HandleDamaged(0, "");
	return Actor.EventTriggerCount;
}

bool Observe_BroadcastInvokesScriptHandler_CopyIndependence(ATestDelegateMulticast First, ATestDelegateMulticast Second)
{
	if (First is null)
	{
		throw("Test_BroadcastInvokesScriptHandler setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_BroadcastInvokesScriptHandler setup: required Second is null");
	}
	First.HandleDamaged(33, "Multicast");
	return First.EventTriggerCount == 1 && Second.EventTriggerCount == 0 && !Second.OnDamaged.IsBound();
}
