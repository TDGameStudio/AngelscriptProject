// Theme: Language.Syntax.Keywords. WorldStory: override keyword on a child method.
// C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Positive block 4 AssertCompiles.
// sha256=4111136a58863104cc677f5b2e967e8380d0f9e8d61335f00a72965ccc536f56; lines 144-154.
// Oracle: AChildActorOvrd.Foo() override is an empty body that completes.
// Extra: ABaseActorOvrd.Foo() also completes; assigning child aliases shares the handle.
// FixtureIsolated.

class ABaseActorOvrd : AActor
{
	void Foo()
	{
	}
}

class AChildActorOvrd : ABaseActorOvrd
{
	void Foo() override
	{
	}
}

int Observe_Override_ChildFooEmptyCompletes(AChildActorOvrd Child)
{
	if (Child is null)
	{
		throw("Test_Keywords_Positive_04 setup: required Child is null");
	}
	Child.Foo();
	return 0;
}

int Observe_Override_BaseFooEmptyCompletes(ABaseActorOvrd Base)
{
	if (Base is null)
	{
		throw("Test_Keywords_Positive_04 setup: required Base is null");
	}
	Base.Foo();
	return 0;
}

bool Observe_Override_AssignChildAliases()
{
	AChildActorOvrd First;
	AChildActorOvrd Second;
	First = Second;
	return First is Second;
}
