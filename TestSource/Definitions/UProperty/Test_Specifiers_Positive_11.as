// Theme: Definitions.UProperty. WorldStory: Meta ClampMin/ClampMax on Health.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Specifiers_Positive AssertCompiles
// UPropSP_Meta; lines 163-169;
// sha256=3ebef64627d00943e1367c5093ba0e2d5e9b7b42a5c9e11b40062794b194f52f.
// Oracle: Health default is 50 on the spawned actor.
// Extra: 0 is ClampMin empty/default; 100 is ClampMax boundary.
// FixtureIsolated.

class AUPropMetaActor : AActor
{
	UPROPERTY(Meta = (ClampMin = 0, ClampMax = 100))
	int Health = 50;
}

bool Observe_Health_Nominal(AUPropMetaActor Actor)
{
	return Actor.Health == 50;
}

bool Observe_Health_ClampMinEmpty(AUPropMetaActor Actor)
{
	int Saved = Actor.Health;
	Actor.Health = 0;
	bool bMin = Actor.Health == 0;
	Actor.Health = Saved;
	return bMin && Saved == 50;
}

bool Observe_Health_ClampMaxBoundary(AUPropMetaActor Actor)
{
	int Saved = Actor.Health;
	Actor.Health = 100;
	bool bMax = Actor.Health == 100;
	Actor.Health = Saved;
	return bMax && Saved == 50;
}
