// Theme: Gameplay.FLinearColor. WorldStory write round-trip via ColorValue.
// C++: AngelscriptCoverageFLinearColorPropertyTests.cpp::FLinearColorWriteRoundTrip
// Oracle VerifyByPath after SetByPath: ColorValue 0.8,0.6,0.4,0.9 then zero then full 1.
// Extra: default ColorValue (0,0,0,1) before write. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFLinearColorWriteActor : AActor
{
	UPROPERTY()
	FLinearColor ColorValue;
}

bool Observe_ColorValue_DefaultEmpty(ACoverageFLinearColorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorWriteRoundTrip setup: required Actor is null");
	}
	return Actor.ColorValue.R == 0.0
		&& Actor.ColorValue.G == 0.0
		&& Actor.ColorValue.B == 0.0
		&& Actor.ColorValue.A == 1.0;
}

bool Observe_ColorValue_WriteRoundTrip(ACoverageFLinearColorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorWriteRoundTrip setup: required Actor is null");
	}
	Actor.ColorValue.R = 0.8;
	Actor.ColorValue.G = 0.6;
	Actor.ColorValue.B = 0.4;
	Actor.ColorValue.A = 0.9;
	return Actor.ColorValue.R == 0.8
		&& Actor.ColorValue.G == 0.6
		&& Actor.ColorValue.B == 0.4
		&& Actor.ColorValue.A == 0.9;
}

bool Observe_ColorValue_WriteZeroBoundary(ACoverageFLinearColorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorWriteRoundTrip setup: required Actor is null");
	}
	Actor.ColorValue.R = 0.0;
	Actor.ColorValue.G = 0.0;
	Actor.ColorValue.B = 0.0;
	Actor.ColorValue.A = 0.0;
	return Actor.ColorValue.R == 0.0 && Actor.ColorValue.A == 0.0;
}

bool Observe_ColorValue_WriteFull(ACoverageFLinearColorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FLinearColorWriteRoundTrip setup: required Actor is null");
	}
	Actor.ColorValue.R = 1.0;
	Actor.ColorValue.G = 1.0;
	Actor.ColorValue.B = 1.0;
	Actor.ColorValue.A = 1.0;
	return Actor.ColorValue.R == 1.0;
}
