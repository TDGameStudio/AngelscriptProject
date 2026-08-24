// Theme: Gameplay.Timer. WorldStory buff duration SetTimer pattern.
// C++: AngelscriptCoverageTimerTests.cpp::TimerUseCaseBuffDuration
// Oracle after BeginPlay ApplySpeedBuff(10): bHasSpeedBuff true.
// Extra: buff false, multiplier 1.0, remaining 0; RemoveSpeedBuff restores defaults.
// Do not spawn from script.

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

	UFUNCTION()
	void ApplySpeedBuff(float Duration)
	{
		Print("Applying speed buff for " + Duration + " seconds");
		bHasSpeedBuff = true;
		SpeedMultiplier = 2.0f;

		// Set timer to remove buff after duration
		BuffHandle = System::SetTimer(this, n"RemoveSpeedBuff", Duration, false);
		BuffRemainingTime = SystemLibrary::GetTimerRemainingTimeHandle(BuffHandle);

		Print("Speed buff active, remaining: " + BuffRemainingTime + " seconds");
	}

	UFUNCTION()
	void RemoveSpeedBuff()
	{
		Print("Speed buff expired");
		bHasSpeedBuff = false;
		SpeedMultiplier = 1.0f;
		BuffRemainingTime = 0.0f;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerUseCaseBuffDuration: Buff duration management");
		ApplySpeedBuff(10.0f);  // 10 second buff
	}
}

bool Observe_BuffDuration_DefaultEmpty(ACoverageTimerBuffDurationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerUseCaseBuffDuration setup: required Actor is null");
	}
	return Actor.bHasSpeedBuff == false
		&& Actor.BuffRemainingTime == 0.0f
		&& Actor.SpeedMultiplier == 1.0f;
}

bool Observe_BuffDuration_RemoveRestoresDefaults(ACoverageTimerBuffDurationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerUseCaseBuffDuration setup: required Actor is null");
	}
	Actor.bHasSpeedBuff = true;
	Actor.SpeedMultiplier = 2.0f;
	Actor.BuffRemainingTime = 10.0f;
	Actor.RemoveSpeedBuff();
	return Actor.bHasSpeedBuff == false
		&& Actor.SpeedMultiplier == 1.0f
		&& Actor.BuffRemainingTime == 0.0f;
}
