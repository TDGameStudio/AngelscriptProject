// Theme: Gameplay.FVector. WorldStory write round-trip of VectorValue.
// C++: AngelscriptCoverageFVectorPropertyTests.cpp::FVectorWriteRoundTrip
// Oracle SetByPath/VerifyByPath: (10,20,30) then negative X -5 / Y -10 / Z -15
// then zero. Extra: default empty (0,0,0). FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFVectorWriteActor : AActor
{
	UPROPERTY()
	FVector VectorValue;
}

bool Observe_VectorValue_DefaultEmpty(ACoverageFVectorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorWriteRoundTrip setup: required Actor is null");
	}
	return Actor.VectorValue.X == 0.0
		&& Actor.VectorValue.Y == 0.0
		&& Actor.VectorValue.Z == 0.0;
}

bool Observe_VectorValue_WritePositive(ACoverageFVectorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorWriteRoundTrip setup: required Actor is null");
	}
	Actor.VectorValue.X = 10.0;
	Actor.VectorValue.Y = 20.0;
	Actor.VectorValue.Z = 30.0;
	return Actor.VectorValue.X == 10.0
		&& Actor.VectorValue.Y == 20.0
		&& Actor.VectorValue.Z == 30.0;
}

bool Observe_VectorValue_WriteNegative(ACoverageFVectorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorWriteRoundTrip setup: required Actor is null");
	}
	Actor.VectorValue.X = -5.0;
	Actor.VectorValue.Y = -10.0;
	Actor.VectorValue.Z = -15.0;
	return Actor.VectorValue.X == -5.0
		&& Actor.VectorValue.Y == -10.0
		&& Actor.VectorValue.Z == -15.0;
}

bool Observe_VectorValue_WriteZeroBoundary(ACoverageFVectorWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FVectorWriteRoundTrip setup: required Actor is null");
	}
	Actor.VectorValue.X = 10.0;
	Actor.VectorValue.X = 0.0;
	Actor.VectorValue.Y = 0.0;
	Actor.VectorValue.Z = 0.0;
	return Actor.VectorValue.X == 0.0
		&& Actor.VectorValue.Y == 0.0
		&& Actor.VectorValue.Z == 0.0;
}

bool Observe_VectorValue_CopyIndependence(ACoverageFVectorWriteActor First, ACoverageFVectorWriteActor Second)
{
	if (First is null)
	{
		throw("Test_FVectorWriteRoundTrip setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FVectorWriteRoundTrip setup: required Second is null");
	}
	First.VectorValue.X = 10.0;
	return First.VectorValue.X == 10.0 && Second.VectorValue.X == 0.0;
}
