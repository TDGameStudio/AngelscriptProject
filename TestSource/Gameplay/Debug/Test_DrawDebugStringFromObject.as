// Theme: Gameplay.Debug. WorldStory DrawDebugStringFromObject from an actor.
// C++: AngelscriptCoverageDebugTests.cpp::DrawDebugStringFromObject
// Oracle VerifyByPath bDrewDebugString true after BeginPlay.
// Extra: default false before BeginPlay. FixtureIsolated. Keep UPROPERTY name.

UCLASS()
class ADebugStringCoverageActor : AActor
{
	UPROPERTY()
	bool bDrewDebugString = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DrawDebugStringFromObject(this, GetActorLocation() + FVector(0.0, 0.0, 25.0), "CoverageDebugString", 0.01f, FLinearColor::Green);
		bDrewDebugString = true;
	}
}

bool Observe_DrawDebugString_DefaultFalse(ADebugStringCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DrawDebugStringFromObject setup: required Actor is null");
	}
	return Actor.bDrewDebugString == false;
}
