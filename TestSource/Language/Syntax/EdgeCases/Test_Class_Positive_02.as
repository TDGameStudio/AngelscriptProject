// Theme: Language.Syntax.EdgeCases. WorldStory: AActor subclass with members.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 2 AssertCompiles.
// sha256=855e8529441c5fbb2e1e7513a52802fcb8d84316c8e0f558e311c38dc66844aa; lines 56-62.
// Oracle: Health defaults to 100; Speed defaults to 5.0f.
// Extra: Health 0 is the empty/false boundary; mutating one instance does not write the other.
// FixtureIsolated.

class AClassMembersActor : AActor
{
	int Health = 100;
	float Speed = 5.0f;
}

int Observe_ClassMembers_DefaultHealth(AClassMembersActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_02 setup: required Actor is null");
	}
	return Actor.Health;
}

float Observe_ClassMembers_DefaultSpeed(AClassMembersActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_02 setup: required Actor is null");
	}
	return Actor.Speed;
}

int Observe_ClassMembers_EmptyHealthBoundary(AClassMembersActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_02 setup: required Actor is null");
	}
	Actor.Health = 0;
	return Actor.Health;
}

int Observe_ClassMembers_CopyIndependentHealth(AClassMembersActor First, AClassMembersActor Second)
{
	if (First is null)
	{
		throw("Test_Class_Positive_02 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Class_Positive_02 setup: required Second is null");
	}
	First.Health = 1;
	Second.Health = 100;
	return First.Health;
}

int Observe_ClassMembers_EmptyHandleIsNull()
{
	AClassMembersActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
