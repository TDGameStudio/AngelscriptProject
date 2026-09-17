/**
 * @version v1
 * @summary InlineEditConditionToggle plus EditCondition metadata. C++ reflects both keys on FProperty. The observers cover the declared defaults and a zero health write with the toggle cleared.
 * @topic Definitions
 */
/**
 * @version root
 * @summary InlineEditConditionToggle plus EditCondition metadata. C++ reflects both keys on FProperty. The observers cover the declared defaults and a zero health write with the toggle cleared.
 * @topic Baseline
 */
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

	/**
	 * Observe the Health default.
	 *
	 * @Kind Observe
	 * @Covers Meta.InlineEditConditionToggleMeta
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
	 * @Covers Meta.InlineEditConditionToggleMeta
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
	 * @Covers Meta.InlineEditConditionToggleMeta
	 * @Inputs none
	 * @Return false
	 */
	UFUNCTION()
	bool EnableSpeedDefault()
	{
		return bEnableSpeed;
	}

	/**
	 * Observe the Speed default.
	 *
	 * @Kind Observe
	 * @Covers Meta.InlineEditConditionToggleMeta
	 * @Inputs none
	 * @Return 5.0
	 */
	UFUNCTION()
	float SpeedDefault()
	{
		return Speed;
	}

	/**
	 * Observe that clearing the toggle and writing zero health is accepted.
	 *
	 * @Kind Observe
	 * @Covers Meta.InlineEditConditionToggleMeta
	 * @Inputs none
	 * @Return 0
	 * @Boundary toggle false and zero health
	 */
	UFUNCTION()
	int ZeroHealthBoundary()
	{
		bEnableHealth = false;
		Health = 0;
		return Health;
	}
}
/** @end */
