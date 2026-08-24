// Theme: Language.Syntax.EdgeCases. WorldStory: final AActor subclass compiles.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 8 AssertCompiles.
// sha256=2c453367cc12e334400fb5e738ff0f4fbbecde0937b542f33d2035f08f76a248; lines 111-113.
// Oracle: AFinalClassActor : AActor final is a valid type.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AFinalClassActor : AActor final
{
}

int Observe_FinalClass_IsAActorWhenSet()
{
	AFinalClassActor Actor;
	if (Actor is AActor)
	{
		return 1;
	}
	return 0;
}

int Observe_FinalClass_EmptyDefaultIsNull()
{
	AFinalClassActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_FinalClass_AssignAliases()
{
	AFinalClassActor First;
	AFinalClassActor Second;
	First = Second;
	return First is Second;
}
