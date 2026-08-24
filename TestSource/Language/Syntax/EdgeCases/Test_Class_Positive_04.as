// Theme: Language.Syntax.EdgeCases. WorldStory: UCLASS with UPROPERTY X.
// C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 4 AssertCompiles.
// sha256=8cd625371fca3fee54be665a5a7f7b17fd389b55763d29cf94a2c00b065976d2; lines 76-83.
// Oracle: UPROPERTY X defaults to 0.
// Extra: X=0 is the empty default; writing X on one instance does not write the other.
// FixtureIsolated. Keep UPROPERTY name X.

UCLASS()
class AClassUCLASSActor : AActor
{
	UPROPERTY()
	int X = 0;
}

int Observe_ClassUCLASS_DefaultX(AClassUCLASSActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_04 setup: required Actor is null");
	}
	return Actor.X;
}

int Observe_ClassUCLASS_WriteBoundary(AClassUCLASSActor Actor)
{
	if (Actor is null)
	{
		throw("Test_Class_Positive_04 setup: required Actor is null");
	}
	Actor.X = 1;
	return Actor.X;
}

int Observe_ClassUCLASS_CopyIndependentX(AClassUCLASSActor First, AClassUCLASSActor Second)
{
	if (First is null)
	{
		throw("Test_Class_Positive_04 setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_Class_Positive_04 setup: required Second is null");
	}
	First.X = 7;
	Second.X = 0;
	return First.X;
}

int Observe_ClassUCLASS_EmptyHandleIsNull()
{
	AClassUCLASSActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}
