// Theme: Language.Syntax.EdgeCases. WorldStory min/max/epsilon via C++ SetByPath.
// C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatFamilyBoundaryValues
// sha256=2974c41a11fc26dec4d0912578475f21a0b52415f239399f945a326836818c7a; lines 374-384.
// Oracle: FloatValue min then max then epsilon; DoubleValue min then max then epsilon.
// Extra: default 0 before C++ writes. FixtureIsolated. Fields stay the C++ VerifyByPath names.

UCLASS()
class ACoverageFloatBoundaryActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;
}

bool Observe_FloatBoundary_DefaultEmpty(ACoverageFloatBoundaryActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatFamilyBoundaryValues setup: required Actor is null");
	}
	return Math::IsNearlyEqual(Actor.FloatValue, 0.0) && Math::IsNearlyEqual(Actor.DoubleValue, 0.0);
}

bool Observe_FloatBoundary_ScriptMinMax(ACoverageFloatBoundaryActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatFamilyBoundaryValues setup: required Actor is null");
	}
	Actor.FloatValue = 1.17549435e-38f;
	Actor.DoubleValue = 2.2250738585072014e-308;
	bool bMin = Actor.FloatValue > 0.0f && Actor.DoubleValue > 0.0;
	Actor.FloatValue = 3.40282347e+38f;
	Actor.DoubleValue = 1.7976931348623157e+308;
	return bMin && Actor.FloatValue > 1.0e+38f && Actor.DoubleValue > 1.0e+308;
}
