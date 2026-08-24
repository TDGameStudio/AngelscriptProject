// Theme: Definitions.UProperty. WorldStory: UPROPERTY bool.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Positive AssertCompiles
// UPropTP_Bool; lines 398-404;
// sha256=157d730bfd248fb15145483a59a5c872711ce23cd9997c4da7300c0c15d1e60a.
// Oracle: bIsAlive default is true on the spawned actor.
// Extra: false empty/default write; copy-independence of a local snapshot.
// FixtureIsolated.

class AUPropBoolActor : AActor
{
	UPROPERTY()
	bool bIsAlive = true;
}

bool Observe_IsAlive_Nominal(AUPropBoolActor Actor)
{
	return Actor.bIsAlive == true;
}

bool Observe_IsAlive_FalseBoundary(AUPropBoolActor Actor)
{
	bool Saved = Actor.bIsAlive;
	Actor.bIsAlive = false;
	bool bCleared = Actor.bIsAlive == false;
	Actor.bIsAlive = Saved;
	return bCleared && Saved == true;
}

bool Observe_IsAlive_CopyIndependence(AUPropBoolActor Actor)
{
	bool Original = Actor.bIsAlive;
	bool Copy = Original;
	Copy = false;
	return Actor.bIsAlive == Original && Copy == false && Original == true;
}
