// Theme: Language.Syntax.EdgeCases. WorldStory: script constructor assigns X.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 6 AssertCompiles.
// sha256=327bee221f36e8f25f77b5257d9b7d865242894e8d0bd0a1d17beac53ae5cc8f; lines 94-100.
// Oracle: AClassCtorActor() sets X to 10.
// Extra: X is not left at 0 after construction; a later write is independent of the ctor store.
// FixtureIsolated.

class AClassCtorActor : AActor
{
	int X;

	AClassCtorActor()
	{
		X = 10;
	}
}

int Observe_ClassCtor_XAfterConstruct(AClassCtorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_06 setup: required Actor is null");
	}
	return Actor.X;
}

int Observe_ClassCtor_NotLeftAtEmptyZero(AClassCtorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_06 setup: required Actor is null");
	}
	if (Actor.X == 0)
	{
		return 0;
	}
	return Actor.X;
}

int Observe_ClassCtor_WriteAfterConstruct(AClassCtorActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_06 setup: required Actor is null");
	}
	Actor.X = 1;
	return Actor.X;
}

int Observe_ClassCtor_EmptyHandleIsNull()
{
	AClassCtorActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
