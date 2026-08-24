// Theme: Definitions.Meta. WorldStory: ClampMin/ClampMax meta on numeric properties.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::ClampMinMaxMeta
// Oracle defaults: ClampedInt 50, ClampedFloat 0.5, ClampedDouble 0.0, OnlyMinInt 10, OnlyMaxInt 100.
// Extra: write 0 / copy independence. FixtureIsolated. Keep C++ property names.

UCLASS()
class ACoverageMetaClampActor : AActor
{
	UPROPERTY(meta = (ClampMin = "0", ClampMax = "100"))
	int ClampedInt = 50;

	UPROPERTY(meta = (ClampMin = "0.0", ClampMax = "1.0"))
	float ClampedFloat = 0.5f;

	UPROPERTY(meta = (ClampMin = "-10.0", ClampMax = "10.0"))
	double ClampedDouble = 0.0;

	UPROPERTY(meta = (ClampMin = "0"))
	int OnlyMinInt = 10;

	UPROPERTY(meta = (ClampMax = "255"))
	int OnlyMaxInt = 100;
}

int Observe_ClampMeta_ClampedIntDefault(ACoverageMetaClampActor Actor)
{
	return Actor.ClampedInt;
}

float Observe_ClampMeta_ClampedFloatDefault(ACoverageMetaClampActor Actor)
{
	return Actor.ClampedFloat;
}

double Observe_ClampMeta_ClampedDoubleDefault(ACoverageMetaClampActor Actor)
{
	return Actor.ClampedDouble;
}

int Observe_ClampMeta_OnlyMinIntDefault(ACoverageMetaClampActor Actor)
{
	return Actor.OnlyMinInt;
}

int Observe_ClampMeta_OnlyMaxIntDefault(ACoverageMetaClampActor Actor)
{
	return Actor.OnlyMaxInt;
}

int Observe_ClampMeta_ZeroBoundary(ACoverageMetaClampActor Actor)
{
	Actor.ClampedInt = 0;
	Actor.OnlyMinInt = 0;
	Actor.OnlyMaxInt = 0;
	return Actor.ClampedInt + Actor.OnlyMinInt + Actor.OnlyMaxInt;
}

bool Observe_ClampMeta_CopyIndependence(ACoverageMetaClampActor First, ACoverageMetaClampActor Second)
{
	First.ClampedInt = 1;
	Second.ClampedInt = 50;
	return First.ClampedInt == 1 && Second.ClampedInt == 50;
}
