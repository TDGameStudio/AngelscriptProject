// Theme: Language.Syntax.Keywords. WorldStory: final class modifier on an actor subclass.
// C++: AngelscriptSyntaxMiscTests.cpp::Keywords_Positive block 3 AssertCompiles.
// sha256=a7cbe3155b3e4b5403ffa5574dd96b8fb592deb0a1ad9fab0110d969cf823686; lines 138-140.
// Oracle: AFinalActorMisc : AActor final is a valid type.
// Extra: default handle is null; assigning aliases the same handle.
// FixtureIsolated.

class AFinalActorMisc : AActor final
{
}

int Observe_FinalActorMisc_IsAActorWhenSet()
{
	AFinalActorMisc Actor;
	if (Actor is AActor)
	{
		return 1;
	}
	return 0;
}

int Observe_FinalActorMisc_EmptyDefaultIsNull()
{
	AFinalActorMisc Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_FinalActorMisc_AssignAliases()
{
	AFinalActorMisc First;
	AFinalActorMisc Second;
	First = Second;
	return First is Second;
}
