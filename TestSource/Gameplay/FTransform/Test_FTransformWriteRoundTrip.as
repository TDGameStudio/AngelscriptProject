// Theme: Gameplay.FTransform. WorldStory write round-trip of Translation/Scale3D.
// C++: AngelscriptCoverageFTransformPropertyTests.cpp::FTransformWriteRoundTrip
// Oracle SetByPath/VerifyByPath: Translation (100,200,300) then Scale3D (2,3,4)
// then negative Translation (-50,-100,-150). Extra: default identity empty;
// zero Translation boundary. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ACoverageFTransformWriteActor : AActor
{
	UPROPERTY()
	FTransform TransformValue;
}

bool Observe_TransformValue_DefaultEmpty(ACoverageFTransformWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformWriteRoundTrip setup: required Actor is null");
	}
	return Actor.TransformValue.GetLocation().X == 0.0
		&& Actor.TransformValue.GetLocation().Y == 0.0
		&& Actor.TransformValue.GetLocation().Z == 0.0
		&& Actor.TransformValue.GetScale3D().X == 1.0;
}

bool Observe_TransformValue_WriteTranslation100(ACoverageFTransformWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformWriteRoundTrip setup: required Actor is null");
	}
	Actor.TransformValue.SetLocation(FVector(100, 200, 300));
	return Actor.TransformValue.GetLocation().X == 100.0
		&& Actor.TransformValue.GetLocation().Y == 200.0
		&& Actor.TransformValue.GetLocation().Z == 300.0;
}

bool Observe_TransformValue_WriteScale234(ACoverageFTransformWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformWriteRoundTrip setup: required Actor is null");
	}
	Actor.TransformValue.SetScale3D(FVector(2, 3, 4));
	return Actor.TransformValue.GetScale3D().X == 2.0
		&& Actor.TransformValue.GetScale3D().Y == 3.0
		&& Actor.TransformValue.GetScale3D().Z == 4.0;
}

bool Observe_TransformValue_WriteNegativeTranslation(ACoverageFTransformWriteActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FTransformWriteRoundTrip setup: required Actor is null");
	}
	Actor.TransformValue.SetLocation(FVector(-50, -100, -150));
	return Actor.TransformValue.GetLocation().X == -50.0
		&& Actor.TransformValue.GetLocation().Y == -100.0
		&& Actor.TransformValue.GetLocation().Z == -150.0;
}

bool Observe_TransformValue_CopyIndependence(ACoverageFTransformWriteActor First, ACoverageFTransformWriteActor Second)
{
	if (First is null)
	{
		throw("Test_FTransformWriteRoundTrip setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_FTransformWriteRoundTrip setup: required Second is null");
	}
	First.TransformValue.SetLocation(FVector(100, 200, 300));
	return First.TransformValue.GetLocation().X == 100.0
		&& Second.TransformValue.GetLocation().X == 0.0;
}
