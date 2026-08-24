// Theme: Definitions.UProperty. WorldStory: NotEditable specifier.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles
// UPropSP_NotEditable; lines 152-158;
// sha256=5d36aa6ac54cb9273a16df90c21d4ce7224a884cf4e488b8dcf717ba33f7975d.
// Oracle: InternalVal default is 0 on the spawned actor.
// Extra: 0 is the empty/default; 1 is a non-zero boundary write then restore.
// FixtureIsolated.

class AUPropNotEditActor : AActor
{
	UPROPERTY(NotEditable)
	int InternalVal = 0;
}

bool Observe_InternalVal_Nominal(AUPropNotEditActor Actor)
{
	return Actor.InternalVal == 0;
}

bool Observe_InternalVal_EmptyDefault(AUPropNotEditActor Actor)
{
	return Actor.InternalVal == 0;
}

bool Observe_InternalVal_BoundaryWrite(AUPropNotEditActor Actor)
{
	int Saved = Actor.InternalVal;
	Actor.InternalVal = 1;
	bool bWrote = Actor.InternalVal == 1;
	Actor.InternalVal = Saved;
	return bWrote && Saved == 0;
}
