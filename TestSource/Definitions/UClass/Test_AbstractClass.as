// Theme: Definitions.UClass. WorldStory Abstract Blueprintable base plus concrete subclass.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::AbstractClass
// Oracle: base CLASS_Abstract; concrete spawns; ApplyShieldDamage(10) leaves Shield=15 DamageApplied=10.
// Extra: GetBaseHealth default 100; ApplyShieldDamage(0) leaves Shield=25. FixtureIsolated.

UCLASS(Abstract, Blueprintable)
class ACoverageClassFeaturesAbstractGameplayBase : AActor
{
	UPROPERTY()
	int BaseHealth = 100;

	UPROPERTY()
	int BaseArmor = 50;

	UFUNCTION()
	int GetBaseHealth()
	{
		return BaseHealth;
	}
}

UCLASS()
class ACoverageClassFeaturesConcreteGameplayActor : ACoverageClassFeaturesAbstractGameplayBase
{
	UPROPERTY()
	int Shield = 25;

	UPROPERTY()
	int DamageApplied = 0;

	UFUNCTION()
	void ApplyShieldDamage(int Damage)
	{
		if (Shield > 0)
		{
			Shield -= Damage;
		}
		DamageApplied = Damage;
	}
}

bool Observe_AbstractBase_EmptyDefaultIsNull()
{
	ACoverageClassFeaturesAbstractGameplayBase Actor;
	return Actor == nullptr;
}

int Observe_GetBaseHealth_Default(ACoverageClassFeaturesConcreteGameplayActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0032 setup: required ACoverageClassFeaturesConcreteGameplayActor is null");
	}
	return Actor.GetBaseHealth();
}

int Observe_ApplyShieldDamage_Nominal(ACoverageClassFeaturesConcreteGameplayActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0032 setup: required ACoverageClassFeaturesConcreteGameplayActor is null");
	}
	Actor.Shield = 25;
	Actor.DamageApplied = 0;
	Actor.ApplyShieldDamage(10);
	return Actor.Shield;
}

int Observe_ApplyShieldDamage_ZeroBoundary(ACoverageClassFeaturesConcreteGameplayActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0032 setup: required ACoverageClassFeaturesConcreteGameplayActor is null");
	}
	Actor.Shield = 25;
	Actor.ApplyShieldDamage(0);
	return Actor.Shield;
}
