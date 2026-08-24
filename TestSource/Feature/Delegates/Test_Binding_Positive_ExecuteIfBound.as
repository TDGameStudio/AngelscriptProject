// Theme: Feature.Delegates. WorldStory ExecuteIfBound on an unbound unicast.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Positive_ExecuteIfBound
// sha256 from theme-refs TS-FEAT-0345; lines 358-371.
// Oracle: AssertCompiles DelBindExecute. Extra: default unbound; Fire is a no-op.
// FixtureIsolated.

delegate void FOnActionExec();

class ADelExecActor : AActor
{
	UPROPERTY()
	FOnActionExec OnAction;

	void Fire()
	{
		OnAction.ExecuteIfBound();
	}
}

bool Observe_ExecuteIfBound_DefaultUnbound(ADelExecActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Binding_Positive_ExecuteIfBound setup: required Actor is null");
	}
	return !Actor.OnAction.IsBound();
}

void Observe_ExecuteIfBound_UnboundFireIsNoOp(ADelExecActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Binding_Positive_ExecuteIfBound setup: required Actor is null");
	}
	Actor.Fire();
}

bool Observe_ExecuteIfBound_TwoLocalsIndependent(ADelExecActor First, ADelExecActor Second)
{
	if (First is null)
	{
		throw("Test_Binding_Positive_ExecuteIfBound setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Binding_Positive_ExecuteIfBound setup: required Second is null");
	}
	First.Fire();
	return !First.OnAction.IsBound() && !Second.OnAction.IsBound();
}
