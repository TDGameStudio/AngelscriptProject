// Theme: Feature.Delegates. C++ compile-fail is DISABLED (#as-engine-behavior):
// BindUFunction is a runtime dynamic bind and does not validate the function name
// at compile time. CSV NegativeDiagnostic is wrong; AssertFailsToCompile is #if 0.
// C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Negative_BindToNonExistentFunction
// sha256 from theme-refs TS-FEAT-0350; lines 472-485.
// Extra: default unbound; two locals independent. Setup is kept as declared and is
// not invoked here (runtime bind of a missing name is runner-owned).

delegate void FOnActionBadFunc();

class ADelBadFuncActor : AActor
{
	UPROPERTY()
	FOnActionBadFunc OnAction;

	void Setup()
	{
		OnAction.BindUFunction(this, n"NonExistentHandler");
	}
}

bool Observe_BindBadFunc_DefaultUnbound(ADelBadFuncActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Binding_Negative_BindToNonExistentFunction setup: required Actor is null");
	}
	return !Actor.OnAction.IsBound();
}

bool Observe_BindBadFunc_TwoLocalsIndependent(ADelBadFuncActor First, ADelBadFuncActor Second)
{
	if (First is null)
	{
		throw("Test_Binding_Negative_BindToNonExistentFunction setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Binding_Negative_BindToNonExistentFunction setup: required Second is null");
	}
	return !First.OnAction.IsBound() && !Second.OnAction.IsBound() && First != Second;
}
