// Theme: Language.Syntax.EdgeCases. WorldStory FQuat component SetByPath round-trip.
// C++: AngelscriptCoverageFQuatPropertyTests.cpp::FQuatWriteRoundTrip
// sha256=5a4e5d814956b7145f9476a6426dc9aef71e4b57e3c10210513bd24ff6688d55; lines 203-210.
// Oracle: QuatValue.X=0.1 Y=0.2 Z=0.3 W=0.9 after C++ writes. Extra: default Identity-like 0,0,0,1.
// FixtureIsolated. Component writes are independent of constructor expressions.

UCLASS()
class ACoverageFQuatWriteActor : AActor
{
	UPROPERTY()
	FQuat QuatValue;
}

bool Observe_FQuatWrite_DefaultEmpty(ACoverageFQuatWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FQuatWriteRoundTrip setup: required Actor is null");
	}
	return Math::IsNearlyEqual(Actor.QuatValue.X, 0.0) && Math::IsNearlyEqual(Actor.QuatValue.Y, 0.0) && Math::IsNearlyEqual(Actor.QuatValue.Z, 0.0) && Math::IsNearlyEqual(Actor.QuatValue.W, 1.0);
}

bool Observe_FQuatWrite_ScriptComponentBoundary(ACoverageFQuatWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FQuatWriteRoundTrip setup: required Actor is null");
	}
	Actor.QuatValue.X = 0.1;
	Actor.QuatValue.Y = 0.2;
	Actor.QuatValue.Z = 0.3;
	Actor.QuatValue.W = 0.9;
	return Math::IsNearlyEqual(Actor.QuatValue.X, 0.1) && Math::IsNearlyEqual(Actor.QuatValue.Y, 0.2) && Math::IsNearlyEqual(Actor.QuatValue.Z, 0.3) && Math::IsNearlyEqual(Actor.QuatValue.W, 0.9);
}
