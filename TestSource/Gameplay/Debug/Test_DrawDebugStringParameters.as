// Theme: Gameplay.Debug. WorldStory default vs explicit DrawDebugStringFromObject params.
// C++: AngelscriptCoverageDebugTests.cpp::DrawDebugStringParameters
// Oracle: DrawDefaultDebugString returns 11; DrawExplicitDebugString returns 23;
// bDefaultParametersDrew true; bExplicitParametersDrew true.
// Extra: both bools default false. FixtureIsolated. Keep UPROPERTY names.

UCLASS()
class ADebugStringParameterCoverageActor : AActor
{
	UPROPERTY()
	bool bDefaultParametersDrew = false;

	UPROPERTY()
	bool bExplicitParametersDrew = false;

	UFUNCTION()
	int DrawDefaultDebugString()
	{
		DrawDebugStringFromObject(this, GetActorLocation(), "CoverageDebugDefaultParameters");
		bDefaultParametersDrew = true;
		return 11;
	}

	UFUNCTION()
	int DrawExplicitDebugString()
	{
		FVector OffsetLocation = GetActorLocation() + FVector(8.0, 16.0, 32.0);
		DrawDebugStringFromObject(this, OffsetLocation, "CoverageDebugExplicitParameters", 0.02f, FLinearColor::Yellow);
		bExplicitParametersDrew = true;
		return 23;
	}
}

bool Observe_DrawDebugStringParameters_DefaultFalse(ADebugStringParameterCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DrawDebugStringParameters setup: required Actor is null");
	}
	return Actor.bDefaultParametersDrew == false && Actor.bExplicitParametersDrew == false;
}

bool Observe_DrawDefaultDebugString_Nominal(ADebugStringParameterCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DrawDebugStringParameters setup: required Actor is null");
	}
	return Actor.DrawDefaultDebugString() == 11 && Actor.bDefaultParametersDrew == true;
}

bool Observe_DrawExplicitDebugString_Nominal(ADebugStringParameterCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DrawDebugStringParameters setup: required Actor is null");
	}
	return Actor.DrawExplicitDebugString() == 23 && Actor.bExplicitParametersDrew == true;
}
