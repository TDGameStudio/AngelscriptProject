// Theme: Feature.Delegates. WorldStory void unicast delegate declaration.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Positive_DelegateVoid
// sha256=93f7589ceb2b5174b102ae9eefcd53d96d8002002cc544f87641a3541e5a25ac; lines 50-58.
// Oracle: AssertCompiles DelDeclBasic. Extra: default unbound; two locals independent.
// FixtureIsolated.

delegate void FOnActionBasic();

class ADelDeclBasicActor : AActor
{
	UPROPERTY()
	FOnActionBasic OnAction;
}

bool Observe_DeclBasic_DefaultUnbound(ADelDeclBasicActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Declaration_Positive_DelegateVoid setup: required Actor is null");
	}
	return !Actor.OnAction.IsBound();
}

bool Observe_DeclBasic_TwoLocalsIndependent(ADelDeclBasicActor First, ADelDeclBasicActor Second)
{
	if (First is null)
	{
		throw("Test_Declaration_Positive_DelegateVoid setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Declaration_Positive_DelegateVoid setup: required Second is null");
	}
	return !First.OnAction.IsBound() && !Second.OnAction.IsBound() && First != Second;
}
