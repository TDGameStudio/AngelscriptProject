// Theme: Language.Syntax.EdgeCases. WorldStory float/double UPROPERTY defaults.
// C++: AngelscriptCoverageFloatPropertyTests.cpp::FloatFamilyDeclarationDefaults
// sha256=095fa2372c67c7e8b2b1e5c7aaa7b214533407d1ebaf59d139ecc6e0cfdf488f; lines 119-135.
// Oracle on instance and CDO: FloatValue=0.0; DoubleValue=0.0; InitializedFloat=1.25;
// InitializedDouble=2.5. Extra: local construct matches those defaults. FixtureIsolated.

UCLASS()
class ACoverageFloatDefaultsActor : AActor
{
	UPROPERTY()
	float FloatValue;

	UPROPERTY()
	double DoubleValue;

	UPROPERTY()
	float InitializedFloat = 1.25f;

	UPROPERTY()
	double InitializedDouble = 2.5;
}

bool Observe_FloatDefaults_UninitializedZero(ACoverageFloatDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatFamilyDeclarationDefaults setup: required Actor is null");
	}
	return Math::IsNearlyEqual(Actor.FloatValue, 0.0) && Math::IsNearlyEqual(Actor.DoubleValue, 0.0);
}

bool Observe_FloatDefaults_InitializedBoundary(ACoverageFloatDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FloatFamilyDeclarationDefaults setup: required Actor is null");
	}
	return Math::IsNearlyEqual(Actor.InitializedFloat, 1.25) && Math::IsNearlyEqual(Actor.InitializedDouble, 2.5);
}
