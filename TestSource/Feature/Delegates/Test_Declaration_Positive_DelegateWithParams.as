// Theme: Feature.Delegates. WorldStory unicast delegate with int and AActor params.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Positive_DelegateWithParams
// sha256=a3319100b72c08022070e903f127b0332de5fca23646ed82bc30ac7d834c9dd5; lines 68-76.
// Oracle: AssertCompiles DelDeclParams. Extra: default unbound; two locals independent.
// FixtureIsolated.

delegate void FOnDamage(int Amount, AActor Instigator);

class ADelDeclParamActor : AActor
{
	UPROPERTY()
	FOnDamage OnDamage;
}

bool Observe_DeclParam_DefaultUnbound(ADelDeclParamActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Declaration_Positive_DelegateWithParams setup: required Actor is null");
	}
	return !Actor.OnDamage.IsBound();
}

bool Observe_DeclParam_TwoLocalsIndependent(ADelDeclParamActor First, ADelDeclParamActor Second)
{
	if (First is null)
	{
		throw("Test_Declaration_Positive_DelegateWithParams setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Declaration_Positive_DelegateWithParams setup: required Second is null");
	}
	return !First.OnDamage.IsBound() && !Second.OnDamage.IsBound() && First != Second;
}
