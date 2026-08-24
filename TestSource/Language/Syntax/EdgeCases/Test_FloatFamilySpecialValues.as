// Theme: Language.Syntax.EdgeCases. WorldStory NaN/Inf write round-trip via C++ SetByPath.
// C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatFamilySpecialValues
// sha256=6afeac2d80156a3ffa7f6edd9881c69d11ddb2b24b3d3b62573db0ed0868b319; lines 449-459.
// Oracle: FloatValue NaN then +Inf then -Inf; DoubleValue follows the same specials.
// Extra: default 0 is finite. FixtureIsolated. NaN is not compared with ==.

UCLASS()
class ACoverageFloatSpecialActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;
}

bool Observe_FloatSpecial_DefaultFiniteEmpty(ACoverageFloatSpecialActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatFamilySpecialValues setup: required Actor is null");
	}
	return Math::IsFinite(Actor.FloatValue) && Math::IsFinite(Actor.DoubleValue) && Math::IsNearlyEqual(Actor.FloatValue, 0.0) && Math::IsNearlyEqual(Actor.DoubleValue, 0.0) && !Math::IsNaN(Actor.FloatValue) && !Math::IsNaN(Actor.DoubleValue);
}
