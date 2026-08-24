// Theme: Definitions.Meta. WorldStory: float Clamp/UI/Units editor meta round-trip.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::FloatEditorMetaSpecifierRoundTrip
// Oracle defaults: PitchDegrees 0, SliderValue 100, TravelDistance 125, HeadingDegrees 90, NormalizedAngle 0.
// Extra: PitchDegrees 0 is the empty vector; write HeadingDegrees 0. FixtureIsolated.

UCLASS()
class ACoverageMetaFloatEditorActor : AActor
{
	UPROPERTY(meta = (ClampMin = "-45.5", ClampMax = "45.5"))
	float PitchDegrees = 0.0f;

	UPROPERTY(meta = (UIMin = "0.25", UIMax = "250.75"))
	float SliderValue = 100.0f;

	UPROPERTY(meta = (ClampMin = "0.0", ClampMax = "1000.0", UIMin = "10.0", UIMax = "900.0", Units = "Centimeters"))
	float TravelDistance = 125.0f;

	UPROPERTY(meta = (Units = "Degrees"))
	float HeadingDegrees = 90.0f;

	UPROPERTY(meta = (ClampMin = "-1.25", ClampMax = "1.25", UIMin = "-1.0", UIMax = "1.0", Units = "Degrees"))
	double NormalizedAngle = 0.0;
}

float Observe_FloatEditor_PitchDegreesDefault(ACoverageMetaFloatEditorActor Actor)
{
	return Actor.PitchDegrees;
}

float Observe_FloatEditor_SliderValueDefault(ACoverageMetaFloatEditorActor Actor)
{
	return Actor.SliderValue;
}

float Observe_FloatEditor_TravelDistanceDefault(ACoverageMetaFloatEditorActor Actor)
{
	return Actor.TravelDistance;
}

float Observe_FloatEditor_HeadingDegreesDefault(ACoverageMetaFloatEditorActor Actor)
{
	return Actor.HeadingDegrees;
}

double Observe_FloatEditor_NormalizedAngleDefault(ACoverageMetaFloatEditorActor Actor)
{
	return Actor.NormalizedAngle;
}

float Observe_FloatEditor_ZeroHeadingBoundary(ACoverageMetaFloatEditorActor Actor)
{
	Actor.HeadingDegrees = 0.0f;
	Actor.SliderValue = 0.0f;
	return Actor.HeadingDegrees + Actor.SliderValue;
}

bool Observe_FloatEditor_CopyIndependence(ACoverageMetaFloatEditorActor First, ACoverageMetaFloatEditorActor Second)
{
	First.TravelDistance = 1.0f;
	Second.TravelDistance = 125.0f;
	return First.TravelDistance == 1.0f && Second.TravelDistance == 125.0f;
}
