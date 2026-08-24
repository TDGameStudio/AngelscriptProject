// Theme: Definitions.UProperty. WorldStory: UPROPERTY float.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Positive AssertCompiles
// UPropTP_Float; lines 387-393;
// sha256=ef123a72e8c7af5e5565aa3f4ef657e6de386196cd35dce732ef82f0d2fa27d2.
// Oracle: Speed default is 5.0f on the spawned actor.
// Extra: 0.0f empty/default write; copy-independence of a local snapshot.
// FixtureIsolated.

class AUPropFloatActor : AActor
{
	UPROPERTY()
	float Speed = 5.0f;
}

bool Observe_Speed_Nominal(AUPropFloatActor Actor)
{
	return Actor.Speed == 5.0f;
}

bool Observe_Speed_EmptyDefault(AUPropFloatActor Actor)
{
	float Saved = Actor.Speed;
	Actor.Speed = 0.0f;
	bool bEmpty = Actor.Speed == 0.0f;
	Actor.Speed = Saved;
	return bEmpty && Saved == 5.0f;
}

bool Observe_Speed_CopyIndependence(AUPropFloatActor Actor)
{
	float Original = Actor.Speed;
	float Copy = Original;
	Copy = 99.0f;
	return Actor.Speed == Original && Copy == 99.0f && Original == 5.0f;
}
