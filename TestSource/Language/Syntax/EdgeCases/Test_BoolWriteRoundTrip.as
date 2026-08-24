// Theme: Language.Syntax.EdgeCases. WorldStory bool write round-trip.
// C++: AngelscriptCoverageBoolPropertyTests.cpp::BoolWriteRoundTrip
// sha256=a7cc3c4d8b7fecf2590578da107a7dfed3023765ec6ef831fe3f4ec335269fc0; lines 190-197.
// Keep UPROPERTY BoolValue. Oracle: write true then false then true.
// Extra: default BoolValue is false. FixtureIsolated.

UCLASS()
class ACoverageBoolWriteActor : AActor
{
	UPROPERTY()
	bool BoolValue;
}

bool Observe_BoolWrite_DefaultEmpty(ACoverageBoolWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BoolWriteRoundTrip setup: required Actor is null");
	}
	return Actor.BoolValue == false;
}

bool Observe_BoolWrite_NominalRoundTrip(ACoverageBoolWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BoolWriteRoundTrip setup: required Actor is null");
	}
	Actor.BoolValue = true;
	if (Actor.BoolValue != true)
	{
		return false;
	}
	Actor.BoolValue = false;
	if (Actor.BoolValue != false)
	{
		return false;
	}
	Actor.BoolValue = true;
	return Actor.BoolValue == true;
}

bool Observe_BoolWrite_InstanceIndependence(ACoverageBoolWriteActor First, ACoverageBoolWriteActor Second)
{
	if (First is null)
	{
		throw("Test_BoolWriteRoundTrip setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_BoolWriteRoundTrip setup: required Second is null");
	}
	First.BoolValue = true;
	return First.BoolValue == true && Second.BoolValue == false;
}
