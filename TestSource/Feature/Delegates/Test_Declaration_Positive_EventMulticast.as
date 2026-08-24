// Theme: Feature.Delegates. WorldStory multicast event declaration.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Positive_EventMulticast
// sha256=f7b2b13fe8441248270d24367c6efb655019bc7792bbd9c4a09dc077648d5f6e; lines 104-112.
// Oracle: AssertCompiles DelDeclEvent. Extra: default unbound; empty Broadcast is a no-op.
// FixtureIsolated.

event void FOnHealthChanged(float NewHealth);

class ADelDeclEventActor : AActor
{
	UPROPERTY()
	FOnHealthChanged OnHealthChanged;
}

bool Observe_DeclEvent_DefaultUnbound(ADelDeclEventActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Declaration_Positive_EventMulticast setup: required Actor is null");
	}
	return !Actor.OnHealthChanged.IsBound();
}

void Observe_DeclEvent_EmptyBroadcastNoOp(ADelDeclEventActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Declaration_Positive_EventMulticast setup: required Actor is null");
	}
	Actor.OnHealthChanged.Broadcast(0.0);
}

bool Observe_DeclEvent_TwoLocalsIndependent(ADelDeclEventActor First, ADelDeclEventActor Second)
{
	if (First is null)
	{
		throw("Test_Declaration_Positive_EventMulticast setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Declaration_Positive_EventMulticast setup: required Second is null");
	}
	First.OnHealthChanged.Broadcast(1.0);
	return !First.OnHealthChanged.IsBound() && !Second.OnHealthChanged.IsBound();
}
