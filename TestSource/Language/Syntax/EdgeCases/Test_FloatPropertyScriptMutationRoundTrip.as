// Theme: Language.Syntax.EdgeCases. WorldStory UFUNCTION mutates float/double UPROPERTY.
// C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatPropertyScriptMutationRoundTrip
// sha256=01024486fd31732ee45ffd25a5bf4fc78a6f99f0c288a849ffac139daf3c42bc; lines 255-286.
// Oracle: AssignValues(12.5, 42.75); AddToFloat(0.25) returns 12.75; AddToDouble(0.125) returns 42.875.
// Extra: defaults 1.5/2.25; zero delta leaves the assigned values. FixtureIsolated.

UCLASS()
class ACoverageFloatScriptMutationActor : AActor
{
	UPROPERTY()
	float FloatValue = 1.5f;

	UPROPERTY()
	double DoubleValue = 2.25;

	UFUNCTION()
	void AssignValues(float NewFloat, double NewDouble)
	{
		FloatValue = NewFloat;
		DoubleValue = NewDouble;
	}

	UFUNCTION()
	float AddToFloat(float Delta)
	{
		FloatValue += Delta;
		return FloatValue;
	}

	UFUNCTION()
	double AddToDouble(double Delta)
	{
		DoubleValue += Delta;
		return DoubleValue;
	}
}

bool Observe_FloatMutation_DefaultEmpty(ACoverageFloatScriptMutationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatPropertyScriptMutationRoundTrip setup: required Actor is null");
	}
	return Math::IsNearlyEqual(Actor.FloatValue, 1.5) && Math::IsNearlyEqual(Actor.DoubleValue, 2.25);
}

bool Observe_FloatMutation_Nominal(ACoverageFloatScriptMutationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatPropertyScriptMutationRoundTrip setup: required Actor is null");
	}
	Actor.AssignValues(12.5f, 42.75);
	float AddedF = Actor.AddToFloat(0.25f);
	double AddedD = Actor.AddToDouble(0.125);
	return Math::IsNearlyEqual(AddedF, 12.75, 0.001) && Math::IsNearlyEqual(Actor.FloatValue, 12.75, 0.001) && Math::IsNearlyEqual(AddedD, 42.875, 0.0001) && Math::IsNearlyEqual(Actor.DoubleValue, 42.875, 0.0001);
}

bool Observe_FloatMutation_ZeroDeltaBoundary(ACoverageFloatScriptMutationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatPropertyScriptMutationRoundTrip setup: required Actor is null");
	}
	Actor.AssignValues(12.5f, 42.75);
	float AddedF = Actor.AddToFloat(0.0f);
	double AddedD = Actor.AddToDouble(0.0);
	return Math::IsNearlyEqual(AddedF, 12.5, 0.001) && Math::IsNearlyEqual(AddedD, 42.75, 0.001);
}
