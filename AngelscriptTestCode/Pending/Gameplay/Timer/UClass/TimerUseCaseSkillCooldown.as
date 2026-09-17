/**
 * @version v1
 * @summary A skill-cooldown SetTimer pattern: UseSkill arms a cooldown timer and a second use while cooling is a no-op. C++ verifies bSkillOnCooldown and SkillUseCount after BeginPlay, so those UPROPERTY names are part of the.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A skill-cooldown SetTimer pattern: UseSkill arms a cooldown timer and a second use while cooling is a no-op. C++ verifies bSkillOnCooldown and SkillUseCount after BeginPlay, so those UPROPERTY names are part of the.
 * @topic Baseline
 */
UCLASS()
class ACoverageTimerSkillCooldownActor : AActor
{
	UPROPERTY()
	bool bSkillOnCooldown = false;

	UPROPERTY()
	float CooldownRemaining = 0.0f;

	UPROPERTY()
	int SkillUseCount = 0;

	FTimerHandle CooldownHandle;

	/**
	 * Use the skill, or no-op when the cooldown is already armed.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerUseCaseSkillCooldown
	 * @Inputs none
	 * @Return SkillUseCount incremented and cooldown armed, or unchanged when cooling
	 */
	UFUNCTION()
	void UseSkill()
	{
		if (bSkillOnCooldown)
		{
			Print("Skill is on cooldown, remaining: " + CooldownRemaining);
			return;
		}

		SkillUseCount++;
		Print("Skill used! Count: " + SkillUseCount);

		bSkillOnCooldown = true;
		CooldownHandle = System::SetTimer(this, n"OnCooldownComplete", 3.0f, false);
		CooldownRemaining = SystemLibrary::GetTimerRemainingTimeHandle(CooldownHandle);
		Print("Cooldown started, " + CooldownRemaining + " seconds remaining");
	}

	/**
	 * Clear the cooldown when the timer fires.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerUseCaseSkillCooldown
	 * @Inputs none
	 * @Return bSkillOnCooldown false
	 */
	UFUNCTION()
	void OnCooldownComplete()
	{
		bSkillOnCooldown = false;
		Print("Cooldown complete, skill ready!");
	}

	/**
	 * WorldStory: BeginPlay uses the skill once so the cooldown is armed.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerUseCaseSkillCooldown
	 * @Inputs none
	 * @Return UseSkill run once
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerUseCaseSkillCooldown: Simulating skill cooldown pattern");
		UseSkill();  // First use should succeed
	}

	/**
	 * Observe that an untouched actor holds the empty cooldown defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerUseCaseSkillCooldown
	 * @Inputs none
	 * @Return true when cooldown is false, remaining is 0 and count is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (bSkillOnCooldown != false)
		{
			return false;
		}
		if (CooldownRemaining != 0.0f)
		{
			return false;
		}
		return SkillUseCount == 0;
	}

	/**
	 * Observe that UseSkill is a no-op while the cooldown is already armed.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerUseCaseSkillCooldown
	 * @Inputs none
	 * @Return true when SkillUseCount stays 0 and cooldown stays true
	 */
	UFUNCTION()
	bool BlockedWhileCooling()
	{
		bSkillOnCooldown = true;
		UseSkill();

		if (SkillUseCount != 0)
		{
			return false;
		}
		return bSkillOnCooldown == true;
	}

	/**
	 * Observe that OnCooldownComplete clears the cooldown flag.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerUseCaseSkillCooldown
	 * @Inputs none
	 * @Return true when bSkillOnCooldown is false
	 */
	UFUNCTION()
	bool OnCooldownCompleteClears()
	{
		bSkillOnCooldown = true;
		OnCooldownComplete();
		return bSkillOnCooldown == false;
	}
}
/** @end */
