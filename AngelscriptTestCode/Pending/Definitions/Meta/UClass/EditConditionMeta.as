/**
 * @version v1
 * @summary EditCondition metadata pointing at sibling bools. C++ reflects the EditCondition keys on FProperty. The observers cover the declared defaults, a disabled zero health write and copy independence.
 * @topic Definitions
 */
/**
 * @version root
 * @summary EditCondition metadata pointing at sibling bools. C++ reflects the EditCondition keys on FProperty. The observers cover the declared defaults, a disabled zero health write and copy independence.
 * @topic Baseline
 */
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

	/**
	 * Observe the Health default.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditConditionMeta
	 * @Inputs none
	 * @Return 100
	 */
	UFUNCTION()
	int HealthDefault()
	{
		return Health;
	}

	/**
	 * Observe the bEnableHealth default.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditConditionMeta
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool EnableHealthDefault()
	{
		return bEnableHealth;
	}

	/**
	 * Observe the bEnableSpeed default.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditConditionMeta
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool EnableSpeedDefault()
	{
		return bEnableSpeed;
	}

	/**
	 * Observe the DamageMultiplier default.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditConditionMeta
	 * @Inputs none
	 * @Return 1.5
	 */
	UFUNCTION()
	float DamageMultiplierDefault()
	{
		return DamageMultiplier;
	}

	/**
	 * Observe that disabling the health flag and writing zero health is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditConditionMeta
	 * @Inputs none
	 * @Return 0
	 * @Boundary disabled flag and zero health
	 */
	UFUNCTION()
	int ZeroHealthAndDisabled()
	{
		bEnableHealth = false;
		Health = 0;
		return Health;
	}

	/**
	 * Observe that writing this instance leaves another instance's default untouched.
	 *
	 * @Kind Observe
	 * @Covers Meta.EditConditionMeta
	 * @Inputs a second actor
	 * @Return true when this reads 1 and the other still reads 100 with health enabled
	 * @Param Second the other actor, expected to keep its declared default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageMetaEditConditionActor Second)
	{
		if (Second is null)
		{
			throw("EditConditionMeta setup: required Second is null");
		}
		Health = 1;
		Second.Health = 100;
		if (Health != 1)
		{
			return false;
		}
		if (Second.Health != 100)
		{
			return false;
		}
		return Second.bEnableHealth;
	}
}
/** @end */
