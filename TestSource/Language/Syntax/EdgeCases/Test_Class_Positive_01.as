// Theme: Language.Syntax.EdgeCases. WorldStory: empty AActor subclass compiles.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 1 AssertCompiles.
// sha256=b2ce12b964b1e99c4b2d7d98cfc0d492edbed6c0889a80883afc7e90183797ec; lines 50-52.
// Oracle: AClassBasicActor is an AActor subclass; default handle is null until assigned.
// Extra: empty default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AClassBasicActor : AActor
{
}

int Observe_ClassBasic_IsAActorWhenSet()
{
	AClassBasicActor Actor;
	if (Actor is AActor)
	{
		return 1;
	}
	return 0;
}

int Observe_ClassBasic_EmptyDefaultIsNull()
{
	AClassBasicActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_ClassBasic_AssignAliases()
{
	AClassBasicActor First;
	AClassBasicActor Second;
	First = Second;
	return First is Second;
}
