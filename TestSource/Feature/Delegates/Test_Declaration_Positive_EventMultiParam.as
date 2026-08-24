// Theme: Feature.Delegates. WorldStory multicast event with FString/int/bool params.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Positive_EventMultiParam
// sha256=e61300bc1049ce058e8353c2618cf2b436697243483f9c63bb6c73a45b4257eb; lines 122-130.
// Oracle: AssertCompiles DelDeclEventMulti. Extra: default unbound; empty-string Broadcast.
// FixtureIsolated.

event void FOnGameEvent(FString EventName, int Data, bool bImportant);

class ADelDeclEventMultiActor : AActor
{
	UPROPERTY()
	FOnGameEvent OnGameEvent;
}

bool Observe_DeclEventMulti_DefaultUnbound(ADelDeclEventMultiActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Declaration_Positive_EventMultiParam setup: required Actor is null");
	}
	return !Actor.OnGameEvent.IsBound();
}

void Observe_DeclEventMulti_EmptyBroadcastNoOp(ADelDeclEventMultiActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Declaration_Positive_EventMultiParam setup: required Actor is null");
	}
	Actor.OnGameEvent.Broadcast("", 0, false);
}

bool Observe_DeclEventMulti_TwoLocalsIndependent(ADelDeclEventMultiActor First, ADelDeclEventMultiActor Second)
{
	if (First is null)
	{
		throw("Test_Declaration_Positive_EventMultiParam setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Declaration_Positive_EventMultiParam setup: required Second is null");
	}
	First.OnGameEvent.Broadcast("Fire", 1, true);
	return !First.OnGameEvent.IsBound() && !Second.OnGameEvent.IsBound();
}
