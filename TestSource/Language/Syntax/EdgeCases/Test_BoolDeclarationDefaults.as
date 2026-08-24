// Theme: Language.Syntax.EdgeCases. WorldStory bool UPROPERTY defaults.
// C++: AngelscriptCoverageBoolPropertyTests.cpp::BoolDeclarationDefaults
// sha256=ce2c84f7a2e593c3ec8ac9853685f9885e64d344cdd12ae107e693c508569640; lines 131-144.
// Oracle after spawn: TrueValue true, FalseValue false, NoDefaultValue false.
// Extra: local construct matches those defaults. FixtureIsolated.

UCLASS()
class ACoverageBoolDefaultsActor : AActor
{
	UPROPERTY()
	bool TrueValue = true;

	UPROPERTY()
	bool FalseValue = false;

	UPROPERTY()
	bool NoDefaultValue;
}

bool Observe_BoolDefaults_Nominal(ACoverageBoolDefaultsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_BoolDeclarationDefaults setup: required Actor is null");
	}
	return Actor.TrueValue == true && Actor.FalseValue == false && Actor.NoDefaultValue == false;
}

bool Observe_BoolDefaults_WriteIndependence(ACoverageBoolDefaultsActor First, ACoverageBoolDefaultsActor Second)
{
	if (First is null)
	{
		throw("Test_BoolDeclarationDefaults setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_BoolDeclarationDefaults setup: required Second is null");
	}
	First.TrueValue = false;
	First.FalseValue = true;
	First.NoDefaultValue = true;
	return First.TrueValue == false && Second.TrueValue == true && Second.FalseValue == false && Second.NoDefaultValue == false;
}
