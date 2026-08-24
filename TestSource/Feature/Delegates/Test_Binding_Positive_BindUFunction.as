// Theme: Feature.Delegates. WorldStory BindUFunction on a unicast delegate.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Positive_BindUFunction
// sha256 from theme-refs TS-FEAT-0343; lines 308-323.
// Oracle: AssertCompiles DelBindUFunc. Extra: unbound before Setup; bound after Setup.
// FixtureIsolated.

delegate void FOnActionBind();

class ADelBindActor : AActor
{
	UPROPERTY()
	FOnActionBind OnAction;

	void HandleAction()
	{
	}

	void Setup()
	{
		OnAction.BindUFunction(this, n"HandleAction");
	}
}

bool Observe_BindUFunction_DefaultUnbound(ADelBindActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Binding_Positive_BindUFunction setup: required Actor is null");
	}
	return !Actor.OnAction.IsBound();
}

bool Observe_BindUFunction_BoundAfterSetup(ADelBindActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Binding_Positive_BindUFunction setup: required Actor is null");
	}
	Actor.Setup();
	return Actor.OnAction.IsBound();
}

bool Observe_BindUFunction_CopyIndependence(ADelBindActor First, ADelBindActor Second)
{
	if (First is null)
	{
		throw("Test_Binding_Positive_BindUFunction setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Binding_Positive_BindUFunction setup: required Second is null");
	}
	First.Setup();
	return First.OnAction.IsBound() && !Second.OnAction.IsBound();
}
