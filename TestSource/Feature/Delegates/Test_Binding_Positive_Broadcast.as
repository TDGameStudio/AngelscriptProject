// Theme: Feature.Delegates. WorldStory Broadcast(42) on a multicast event.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Positive_Broadcast
// sha256 from theme-refs TS-FEAT-0346; lines 381-394.
// Oracle: AssertCompiles DelBindBroadcast. Extra: default unbound; Fire is a no-op;
// Broadcast 0 is the zero boundary. FixtureIsolated.

event void FOnChangedBroadcast(int Val);

class ADelBroadcastActor : AActor
{
	UPROPERTY()
	FOnChangedBroadcast OnChanged;

	void Fire()
	{
		OnChanged.Broadcast(42);
	}
}

bool Observe_Broadcast_DefaultUnbound(ADelBroadcastActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Binding_Positive_Broadcast setup: required Actor is null");
	}
	return !Actor.OnChanged.IsBound();
}

void Observe_Broadcast_UnboundFireIsNoOp(ADelBroadcastActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Binding_Positive_Broadcast setup: required Actor is null");
	}
	Actor.Fire();
	Actor.OnChanged.Broadcast(0);
}

bool Observe_Broadcast_TwoLocalsIndependent(ADelBroadcastActor First, ADelBroadcastActor Second)
{
	if (First is null)
	{
		throw("Test_Binding_Positive_Broadcast setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Binding_Positive_Broadcast setup: required Second is null");
	}
	First.Fire();
	return !First.OnChanged.IsBound() && !Second.OnChanged.IsBound();
}
