// Theme: Definitions.UProperty. WorldStory: UPROPERTY FVector.
// C++: AngelscriptSyntaxUPropertyTests.cpp::Types_Positive AssertCompiles
// UPropTP_FVector; lines 420-426;
// sha256=d1fe8fa64b1e946d477e6ccd60017f7b7ab866ba8d6cecbcef2961f38d73d9be.
// Oracle: Location default is FVector(0,0,0) on the spawned actor.
// Extra: Zero vector is the empty/default; (1,2,3) is a non-zero boundary write.
// FixtureIsolated.

class AUPropVecActor : AActor
{
	UPROPERTY()
	FVector Location;
}

bool Observe_Location_Nominal(AUPropVecActor Actor)
{
	return Actor.Location.Equals(FVector(0.0f, 0.0f, 0.0f));
}

bool Observe_Location_EmptyDefault(AUPropVecActor Actor)
{
	return Actor.Location.IsNearlyZero();
}

bool Observe_Location_CopyIndependence(AUPropVecActor Actor)
{
	FVector Original = Actor.Location;
	FVector Copy = Original;
	Copy = FVector(1.0f, 2.0f, 3.0f);
	return Actor.Location.Equals(Original) && Copy.Equals(FVector(1.0f, 2.0f, 3.0f));
}
