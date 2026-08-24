// Theme: Definitions.UProperty. WorldStory: UPROPERTY int.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Positive AssertCompiles
// UPropTP_Int; lines 376-382;
// sha256=ef652f4503868c7f0cce50fe5946c178ad552c8591ec62cbe1c1e2520f6a33e1.
// Oracle: Health default is 100 on the spawned actor.
// Extra: 0 empty/default write; copy-independence of a local snapshot.
// FixtureIsolated.

class AUPropIntActor : AActor
{
	UPROPERTY()
	int Health = 100;
}

bool Observe_Health_Nominal(AUPropIntActor Actor)
{
	return Actor.Health == 100;
}

bool Observe_Health_EmptyDefault(AUPropIntActor Actor)
{
	int Saved = Actor.Health;
	Actor.Health = 0;
	bool bEmpty = Actor.Health == 0;
	Actor.Health = Saved;
	return bEmpty && Saved == 100;
}

bool Observe_Health_CopyIndependence(AUPropIntActor Actor)
{
	int Original = Actor.Health;
	int Copy = Original;
	Copy = -1;
	return Actor.Health == Original && Copy == -1 && Original == 100;
}
