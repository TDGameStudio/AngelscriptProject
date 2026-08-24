// Theme: Definitions.Meta. WorldStory: InlineEditConditionToggle plus EditCondition.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::InlineEditConditionToggleMeta
// Oracle defaults: bEnableHealth true, Health 100, bEnableSpeed false, Speed 5.0.
// Extra: Health 0; toggle false. FixtureIsolated.

UCLASS()
class ACoverageMetaInlineToggleActor : AActor
{
	UPROPERTY(meta = (InlineEditConditionToggle))
	bool bEnableHealth = true;

	UPROPERTY(meta = (EditCondition = "bEnableHealth"))
	int Health = 100;

	UPROPERTY(meta = (InlineEditConditionToggle))
	bool bEnableSpeed = false;

	UPROPERTY(meta = (EditCondition = "bEnableSpeed"))
	float Speed = 5.0f;
}

int Observe_InlineToggle_HealthDefault(ACoverageMetaInlineToggleActor Actor)
{
	return Actor.Health;
}

bool Observe_InlineToggle_EnableHealthDefault(ACoverageMetaInlineToggleActor Actor)
{
	return Actor.bEnableHealth;
}

bool Observe_InlineToggle_EnableSpeedDefault(ACoverageMetaInlineToggleActor Actor)
{
	return Actor.bEnableSpeed;
}

float Observe_InlineToggle_SpeedDefault(ACoverageMetaInlineToggleActor Actor)
{
	return Actor.Speed;
}

int Observe_InlineToggle_ZeroHealthBoundary(ACoverageMetaInlineToggleActor Actor)
{
	Actor.bEnableHealth = false;
	Actor.Health = 0;
	return Actor.Health;
}
