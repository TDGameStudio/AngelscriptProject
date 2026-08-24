// Theme: Gameplay.Timer. WorldStory skill cooldown SetTimer pattern.
// C++: AngelscriptCoverageTimerTests.cpp::TimerUseCaseSkillCooldown
// Oracle after BeginPlay UseSkill: bSkillOnCooldown true, SkillUseCount 1.
// Extra: cooldown false / count 0; second UseSkill while cooling is a no-op.
// Do not spawn from script.

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

		// Start cooldown
		bSkillOnCooldown = true;
		CooldownHandle = System::SetTimer(this, n"OnCooldownComplete", 3.0f, false);
		CooldownRemaining = SystemLibrary::GetTimerRemainingTimeHandle(CooldownHandle);
		Print("Cooldown started, " + CooldownRemaining + " seconds remaining");
	}

	UFUNCTION()
	void OnCooldownComplete()
	{
		bSkillOnCooldown = false;
		Print("Cooldown complete, skill ready!");
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerUseCaseSkillCooldown: Simulating skill cooldown pattern");
		UseSkill();  // First use should succeed
	}
}

bool Observe_SkillCooldown_DefaultEmpty(ACoverageTimerSkillCooldownActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerUseCaseSkillCooldown setup: required Actor is null");
	}
	return Actor.bSkillOnCooldown == false
		&& Actor.CooldownRemaining == 0.0f
		&& Actor.SkillUseCount == 0;
}

bool Observe_SkillCooldown_BlockedWhileCooling(ACoverageTimerSkillCooldownActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerUseCaseSkillCooldown setup: required Actor is null");
	}
	Actor.bSkillOnCooldown = true;
	Actor.UseSkill();
	return Actor.SkillUseCount == 0 && Actor.bSkillOnCooldown == true;
}

bool Observe_SkillCooldown_OnCooldownCompleteClears(ACoverageTimerSkillCooldownActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerUseCaseSkillCooldown setup: required Actor is null");
	}
	Actor.bSkillOnCooldown = true;
	Actor.OnCooldownComplete();
	return Actor.bSkillOnCooldown == false;
}
