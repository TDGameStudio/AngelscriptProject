// Theme: Language.Syntax.EdgeCases. WorldStory: two-class inheritance chain.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 7 AssertCompiles.
// sha256=839eca7f3a83783798913b873439e8916c1b413b810668e96af9000d1cea859c; lines 104-107.
// Oracle: AChildChainActor subclasses ABaseChainActor.
// Extra: default child handle is null; upcast child handle stays a child when set.
// FixtureIsolated.

class ABaseChainActor : AActor
{
}

class AChildChainActor : ABaseChainActor
{
}

int Observe_Chain_ChildIsBaseWhenSet()
{
	AChildChainActor Child;
	ABaseChainActor Base = Child;
	if (Base is ABaseChainActor)
	{
		return 1;
	}
	return 0;
}

int Observe_Chain_EmptyChildDefaultNull()
{
	AChildChainActor Child;
	if (Child is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_Chain_AssignChildAliases()
{
	AChildChainActor First;
	AChildChainActor Second;
	First = Second;
	return First is Second;
}
