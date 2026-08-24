// Theme: Gameplay.FRotator. WorldStory write round-trip via RotatorValue.
// C++: AngelscriptCoverageFRotatorPropertyTests.cpp::FRotatorWriteRoundTrip
// Oracle: write 45/90/180 then negative -30/-60/-90 then zero Pitch 0.
// Extra: default RotatorValue Zero before write. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFRotatorWriteActor : AActor
{
	UPROPERTY()
	FRotator RotatorValue;
}

bool Observe_RotatorValue_DefaultEmpty(ACoverageFRotatorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorWriteRoundTrip setup: required Actor is null");
	}
	return Actor.RotatorValue.Pitch == 0.0
		&& Actor.RotatorValue.Yaw == 0.0
		&& Actor.RotatorValue.Roll == 0.0;
}

bool Observe_RotatorValue_WritePositive(ACoverageFRotatorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorWriteRoundTrip setup: required Actor is null");
	}
	Actor.RotatorValue.Pitch = 45.0;
	Actor.RotatorValue.Yaw = 90.0;
	Actor.RotatorValue.Roll = 180.0;
	return Actor.RotatorValue.Pitch == 45.0
		&& Actor.RotatorValue.Yaw == 90.0
		&& Actor.RotatorValue.Roll == 180.0;
}

bool Observe_RotatorValue_WriteNegative(ACoverageFRotatorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorWriteRoundTrip setup: required Actor is null");
	}
	Actor.RotatorValue.Pitch = -30.0;
	Actor.RotatorValue.Yaw = -60.0;
	Actor.RotatorValue.Roll = -90.0;
	return Actor.RotatorValue.Pitch == -30.0;
}

bool Observe_RotatorValue_WriteZero(ACoverageFRotatorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FRotatorWriteRoundTrip setup: required Actor is null");
	}
	Actor.RotatorValue.Pitch = 0.0;
	Actor.RotatorValue.Yaw = 0.0;
	Actor.RotatorValue.Roll = 0.0;
	return Actor.RotatorValue.Pitch == 0.0;
}
