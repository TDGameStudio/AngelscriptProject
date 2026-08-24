// Theme: Definitions.UFunction. WorldStory: unnamed UFUNCTION parameter is valid.
// C++: AngelscriptSyntaxUFunctionTests.cpp::Params_UnnamedParameter AssertCompiles.
// sha256=8ac274b1c8f3d998b5c4fbb6839c9c683da51194a65b6e4a9f7c5f8bdc354a89; lines 366-372.
// Oracle: AUFuncPNoNameActor.Foo(int) compiles without a parameter name.
// Extra: Foo(0) is the zero boundary; empty default handle is null.
// FixtureIsolated.

class AUFuncPNoNameActor : AActor
{
	UFUNCTION()
	void Foo(int)
	{
	}
}

int Observe_UnnamedParam_CallCompletes(AUFuncPNoNameActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Params_UnnamedParameter setup: required Actor is null");
	}
	Actor.Foo(7);
	return 0;
}

int Observe_UnnamedParam_ZeroBoundary(AUFuncPNoNameActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Params_UnnamedParameter setup: required Actor is null");
	}
	Actor.Foo(0);
	return 0;
}

int Observe_UnnamedParam_EmptyDefaultIsNull()
{
	AUFuncPNoNameActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
