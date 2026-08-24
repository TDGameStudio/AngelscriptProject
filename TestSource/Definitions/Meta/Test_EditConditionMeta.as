// Theme: Definitions.Meta. WorldStory: EditCondition meta pointing at sibling bools.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::EditConditionMeta
// Oracle defaults: bEnableHealth true, Health 100, bEnableSpeed false, Speed 5.0, bEnableDamage true, DamageMultiplier 1.5.
// Extra: disable flags / Health 0. FixtureIsolated.

UCLASS()
class ACoverageMetaEditConditionActor : AActor
{
	UPROPERTY()
	bool bEnableHealth = true;

	UPROPERTY(meta = (EditCondition = "bEnableHealth"))
	int Health = 100;

	UPROPERTY()
	bool bEnableSpeed = false;

	UPROPERTY(meta = (EditCondition = "bEnableSpeed"))
	float Speed = 5.0f;

	UPROPERTY()
	bool bEnableDamage = true;

	UPROPERTY(meta = (EditCondition = "bEnableDamage"))
	float DamageMultiplier = 1.5f;
}

int Observe_EditCondition_HealthDefault(ACoverageMetaEditConditionActor Actor)
{
	return Actor.Health;
}

bool Observe_EditCondition_EnableHealthDefault(ACoverageMetaEditConditionActor Actor)
{
	return Actor.bEnableHealth;
}

bool Observe_EditCondition_EnableSpeedDefault(ACoverageMetaEditConditionActor Actor)
{
	return Actor.bEnableSpeed;
}

float Observe_EditCondition_DamageMultiplierDefault(ACoverageMetaEditConditionActor Actor)
{
	return Actor.DamageMultiplier;
}

int Observe_EditCondition_ZeroHealthAndDisabled(ACoverageMetaEditConditionActor Actor)
{
	Actor.bEnableHealth = false;
	Actor.Health = 0;
	return Actor.Health;
}

bool Observe_EditCondition_CopyIndependence(ACoverageMetaEditConditionActor First, ACoverageMetaEditConditionActor Second)
{
	First.Health = 1;
	Second.Health = 100;
	return First.Health == 1 && Second.Health == 100 && Second.bEnableHealth;
}
