// Theme: Feature.Delegates. WorldStory AddUFunction on a multicast event.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Positive_AddUFunction
// sha256 from theme-refs TS-FEAT-0344; lines 333-348.
// Oracle: AssertCompiles DelBindAddUFunc. Extra: unbound before Setup; bound after Setup.
// FixtureIsolated.

event void FOnChangedBind(int Val);

class ADelBindAddActor : AActor
{
	UPROPERTY()
	FOnChangedBind OnChanged;

	void HandleChanged(int Val)
	{
	}

	void Setup()
	{
		OnChanged.AddUFunction(this, n"HandleChanged");
	}
}

bool Observe_AddUFunction_DefaultUnbound(ADelBindAddActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Binding_Positive_AddUFunction setup: required Actor is null");
	}
	return !Actor.OnChanged.IsBound();
}

bool Observe_AddUFunction_BoundAfterSetup(ADelBindAddActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Binding_Positive_AddUFunction setup: required Actor is null");
	}
	Actor.Setup();
	return Actor.OnChanged.IsBound();
}

bool Observe_AddUFunction_CopyIndependence(ADelBindAddActor First, ADelBindAddActor Second)
{
	if (First is null)
	{
		throw("Test_Binding_Positive_AddUFunction setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Binding_Positive_AddUFunction setup: required Second is null");
	}
	First.Setup();
	First.OnChanged.Broadcast(0);
	return First.OnChanged.IsBound() && !Second.OnChanged.IsBound();
}
