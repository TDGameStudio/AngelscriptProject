/**
 * @version v1
 * @summary A buff-duration SetTimer pattern: ApplySpeedBuff arms a timer that later restores defaults. C++ verifies bHasSpeedBuff after BeginPlay ApplySpeedBuff(10), so those UPROPERTY names are part of the contract and are kept.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A buff-duration SetTimer pattern: ApplySpeedBuff arms a timer that later restores defaults. C++ verifies bHasSpeedBuff after BeginPlay ApplySpeedBuff(10), so those UPROPERTY names are part of the contract and are kept.
 * @topic Baseline
 */
UCLASS()
class ACoverageTimerBuffDurationActor : AActor
{
	UPROPERTY()
	bool bHasSpeedBuff = false;

	UPROPERTY()
	float BuffRemainingTime = 0.0f;

	UPROPERTY()
	float SpeedMultiplier = 1.0f;

	FTimerHandle BuffHandle;

	/**
	 * Apply a speed buff and arm a timer to remove it after Duration.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerUseCaseBuffDuration
	 * @Inputs a duration in seconds
	 * @Return bHasSpeedBuff true, SpeedMultiplier 2, remaining time from the handle
	 * @Param Duration how long the buff lasts
	 */
	UFUNCTION()
	void ApplySpeedBuff(float Duration)
	{
		Print("Applying speed buff for " + Duration + " seconds");
		bHasSpeedBuff = true;
		SpeedMultiplier = 2.0f;

		BuffHandle = System::SetTimer(this, n"RemoveSpeedBuff", Duration, false);
		BuffRemainingTime = SystemLibrary::GetTimerRemainingTimeHandle(BuffHandle);

		Print("Speed buff active, remaining: " + BuffRemainingTime + " seconds");
	}

	/**
	 * Restore the default speed when the buff timer fires.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerUseCaseBuffDuration
	 * @Inputs none
	 * @Return buff false, multiplier 1, remaining 0
	 */
	UFUNCTION()
	void RemoveSpeedBuff()
	{
		Print("Speed buff expired");
		bHasSpeedBuff = false;
		SpeedMultiplier = 1.0f;
		BuffRemainingTime = 0.0f;
	}

	/**
	 * WorldStory: BeginPlay applies a ten-second speed buff.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerUseCaseBuffDuration
	 * @Inputs none
	 * @Return ApplySpeedBuff(10) run
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerUseCaseBuffDuration: Buff duration management");
		ApplySpeedBuff(10.0f);  // 10 second buff
	}

	/**
	 * Observe that an untouched actor holds the empty buff defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerUseCaseBuffDuration
	 * @Inputs none
	 * @Return true when buff is false, remaining is 0 and multiplier is 1
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (bHasSpeedBuff != false)
		{
			return false;
		}
		if (BuffRemainingTime != 0.0f)
		{
			return false;
		}
		return SpeedMultiplier == 1.0f;
	}

	/**
	 * Observe that RemoveSpeedBuff restores the default speed fields.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerUseCaseBuffDuration
	 * @Inputs none
	 * @Return true when buff is false, multiplier is 1 and remaining is 0
	 */
	UFUNCTION()
	bool RemoveRestoresDefaults()
	{
		bHasSpeedBuff = true;
		SpeedMultiplier = 2.0f;
		BuffRemainingTime = 10.0f;
		RemoveSpeedBuff();

		if (bHasSpeedBuff != false)
		{
			return false;
		}
		if (SpeedMultiplier != 1.0f)
		{
			return false;
		}
		return BuffRemainingTime == 0.0f;
	}
}
/** @end */
