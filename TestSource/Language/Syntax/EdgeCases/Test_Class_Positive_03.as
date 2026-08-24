// Theme: Language.Syntax.EdgeCases. WorldStory: AActor subclass with methods.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 3 AssertCompiles.
// sha256=89000990062cf610c327308f5afe895a2b30ad4fc5c6d8ffc08b4f1937bbd193; lines 66-72.
// Oracle: Bar returns 1; Foo is an empty body that completes.
// Extra: Foo then Bar still returns 1; empty Foo yields 0 from a helper.
// FixtureIsolated.

class AClassMethodsActor : AActor
{
	void Foo()
	{
	}

	int Bar()
	{
		return 1;
	}
}

int Observe_ClassMethods_BarNominal(AClassMethodsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_03 setup: required Actor is null");
	}
	return Actor.Bar();
}

int Observe_ClassMethods_FooEmptyCompletes(AClassMethodsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_03 setup: required Actor is null");
	}
	Actor.Foo();
	return 0;
}

int Observe_ClassMethods_FooThenBarBoundary(AClassMethodsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_03 setup: required Actor is null");
	}
	Actor.Foo();
	return Actor.Bar();
}

int Observe_ClassMethods_EmptyHandleIsNull()
{
	AClassMethodsActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
