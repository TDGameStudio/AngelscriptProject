// Theme: Definitions.Meta. WorldStory: Units meta on float properties.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::UnitsMeta
// Oracle defaults: AngleDegrees 90, AngleRadians 1.5708, DistanceCM 100, DistanceM 1,
// TimeSeconds 5, TimeMS 5000, Percentage 75, MassKG 10.
// Extra: write 0. FixtureIsolated.

UCLASS()
class ACoverageMetaUnitsActor : AActor
{
	UPROPERTY(meta = (Units = "Degrees"))
	float AngleDegrees = 90.0f;

	UPROPERTY(meta = (Units = "Radians"))
	float AngleRadians = 1.5708f;

	UPROPERTY(meta = (Units = "Centimeters"))
	float DistanceCM = 100.0f;

	UPROPERTY(meta = (Units = "Meters"))
	float DistanceM = 1.0f;

	UPROPERTY(meta = (Units = "Seconds"))
	float TimeSeconds = 5.0f;

	UPROPERTY(meta = (Units = "Milliseconds"))
	float TimeMS = 5000.0f;

	UPROPERTY(meta = (Units = "Percent"))
	float Percentage = 75.0f;

	UPROPERTY(meta = (Units = "kg"))
	float MassKG = 10.0f;
}

float Observe_UnitsMeta_AngleDegreesDefault(ACoverageMetaUnitsActor Actor)
{
	return Actor.AngleDegrees;
}

float Observe_UnitsMeta_DistanceCMDefault(ACoverageMetaUnitsActor Actor)
{
	return Actor.DistanceCM;
}

float Observe_UnitsMeta_TimeSecondsDefault(ACoverageMetaUnitsActor Actor)
{
	return Actor.TimeSeconds;
}

float Observe_UnitsMeta_PercentageDefault(ACoverageMetaUnitsActor Actor)
{
	return Actor.Percentage;
}

float Observe_UnitsMeta_MassKGDefault(ACoverageMetaUnitsActor Actor)
{
	return Actor.MassKG;
}

float Observe_UnitsMeta_ZeroBoundary(ACoverageMetaUnitsActor Actor)
{
	Actor.AngleDegrees = 0.0f;
	Actor.DistanceCM = 0.0f;
	Actor.MassKG = 0.0f;
	return Actor.AngleDegrees + Actor.DistanceCM + Actor.MassKG;
}
