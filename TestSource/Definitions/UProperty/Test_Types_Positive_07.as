// Theme: Definitions.UProperty. WorldStory: UPROPERTY TSubclassOf<AActor>.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Positive AssertCompiles
// UPropTP_TSubclassOf; lines 442-448;
// sha256=afada7c27457809f02ecd40ed365fabe4f87005fd976a9428bb34802fe9b4b6d.
// Oracle: ActorClass default is null on the spawned actor.
// Extra: null is the empty/default; assigning AActor::StaticClass() is the live boundary.
// FixtureIsolated.

class AUPropSubclassActor : AActor
{
	UPROPERTY()
	TSubclassOf<AActor> ActorClass;
}

bool Observe_ActorClass_Nominal(AUPropSubclassActor Actor)
{
	return Actor.ActorClass == nullptr;
}

bool Observe_ActorClass_EmptyDefault(AUPropSubclassActor Actor)
{
	return Actor.ActorClass == nullptr;
}

bool Observe_ActorClass_AssignBoundary(AUPropSubclassActor Actor)
{
	TSubclassOf<AActor> Saved = Actor.ActorClass;
	Actor.ActorClass = AActor::StaticClass();
	bool bAssigned = Actor.ActorClass != nullptr;
	Actor.ActorClass = Saved;
	return bAssigned && Saved == nullptr;
}
