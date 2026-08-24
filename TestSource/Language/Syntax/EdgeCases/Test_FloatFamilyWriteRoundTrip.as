// Theme: Language.Syntax.EdgeCases. WorldStory C++ SetByPath/VerifyByPath float write.
// C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatFamilyWriteRoundTrip
// sha256=90e00c692f2bf27311657cd2e3c4d6ffd7e62c94a96c0894f2903a924478f83b; lines 196-206.
// Oracle: FloatValue 3.14159 then -2.71828; DoubleValue 1.4142135623730951 then -1.7320508075688772.
// Extra: default 0 before any write. FixtureIsolated. Script assignment is copy into UPROPERTY.

UCLASS()
class ACoverageFloatWriteActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;
}

bool Observe_FloatWrite_DefaultEmpty(ACoverageFloatWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatFamilyWriteRoundTrip setup: required Actor is null");
	}
	return Math::IsNearlyEqual(Actor.FloatValue, 0.0) && Math::IsNearlyEqual(Actor.DoubleValue, 0.0);
}

bool Observe_FloatWrite_ScriptRoundTripBoundary(ACoverageFloatWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatFamilyWriteRoundTrip setup: required Actor is null");
	}
	Actor.FloatValue = 3.14159f;
	Actor.DoubleValue = 1.4142135623730951;
	bool bPositive = Math::IsNearlyEqual(Actor.FloatValue, 3.14159, 0.00001) && Math::IsNearlyEqual(Actor.DoubleValue, 1.4142135623730951, 0.00001);
	Actor.FloatValue = -2.71828f;
	Actor.DoubleValue = -1.7320508075688772;
	return bPositive && Math::IsNearlyEqual(Actor.FloatValue, -2.71828, 0.00001) && Math::IsNearlyEqual(Actor.DoubleValue, -1.7320508075688772, 0.00001);
}
