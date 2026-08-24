// Theme: Feature.Delegates. WorldStory unicast delegate with bool return.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Declaration_Positive_DelegateWithReturn
// sha256=8e64ca15464e2c3a50a474f7560006c9b41ab2066b78cce4edb0cf379c723b79; lines 86-94.
// Oracle: AssertCompiles DelDeclReturn. Extra: default unbound; two locals independent.
// FixtureIsolated.

delegate bool FValidateAction(int ActionId);

class ADelDeclReturnActor : AActor
{
	UPROPERTY()
	FValidateAction Validator;
}

bool Observe_DeclReturn_DefaultUnbound(ADelDeclReturnActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Declaration_Positive_DelegateWithReturn setup: required Actor is null");
	}
	return !Actor.Validator.IsBound();
}

bool Observe_DeclReturn_TwoLocalsIndependent(ADelDeclReturnActor First, ADelDeclReturnActor Second)
{
	if (First is null)
	{
		throw("Test_Declaration_Positive_DelegateWithReturn setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Declaration_Positive_DelegateWithReturn setup: required Second is null");
	}
	return !First.Validator.IsBound() && !Second.Validator.IsBound() && First != Second;
}
