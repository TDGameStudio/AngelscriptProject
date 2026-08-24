// Theme: Gameplay.FVector2D. WorldStory write round-trip of VectorValue.
// C++: AngelscriptCoverageFVector2DPropertyTests.cpp::FVector2DWriteRoundTrip
// Oracle SetByPath/VerifyByPath: (100,200) then (-50,-75) then (0,0).
// Extra: default empty (0,0). FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFVector2DWriteActor : AActor
{
	UPROPERTY()
	FVector2D VectorValue;
}

bool Observe_VectorValue_DefaultEmpty(ACoverageFVector2DWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DWriteRoundTrip setup: required Actor is null");
	}
	return Actor.VectorValue.X == 0.0 && Actor.VectorValue.Y == 0.0;
}

bool Observe_VectorValue_WritePositive(ACoverageFVector2DWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DWriteRoundTrip setup: required Actor is null");
	}
	Actor.VectorValue.X = 100.0;
	Actor.VectorValue.Y = 200.0;
	return Actor.VectorValue.X == 100.0 && Actor.VectorValue.Y == 200.0;
}

bool Observe_VectorValue_WriteNegative(ACoverageFVector2DWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DWriteRoundTrip setup: required Actor is null");
	}
	Actor.VectorValue.X = -50.0;
	Actor.VectorValue.Y = -75.0;
	return Actor.VectorValue.X == -50.0 && Actor.VectorValue.Y == -75.0;
}

bool Observe_VectorValue_WriteZeroBoundary(ACoverageFVector2DWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVector2DWriteRoundTrip setup: required Actor is null");
	}
	Actor.VectorValue.X = 100.0;
	Actor.VectorValue.X = 0.0;
	Actor.VectorValue.Y = 0.0;
	return Actor.VectorValue.X == 0.0 && Actor.VectorValue.Y == 0.0;
}

bool Observe_VectorValue_CopyIndependence(ACoverageFVector2DWriteActor First, ACoverageFVector2DWriteActor Second)
{
	if (First is null)
	{
		throw("Test_FVector2DWriteRoundTrip setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FVector2DWriteRoundTrip setup: required Second is null");
	}
	First.VectorValue.X = 100.0;
	return First.VectorValue.X == 100.0 && Second.VectorValue.X == 0.0;
}
