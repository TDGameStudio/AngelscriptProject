// Theme: Gameplay.Timer. C++ compiles then VerifyByPath UI/AI timer setup flags.
// CSV NegativeDiagnostic; method is a pattern oracle, not a compile-fail.
// C++: AngelscriptCoverageTimerTests.cpp::TimerUiCountdownAndAiStatePatterns
// Oracle after BeginPlay: bPromptVisible true, CountdownValue 3, bCanAttack false,
// bAlertState false, all four *TimerActiveAfterSetup true.
// Extra: defaults 0/false; HidePrompt/AdvanceCountdown/UnlockAttack/EnterAlertState
// mutate state without spawning. Do not spawn from script.

UCLASS()
class ACoverageTimerUiCountdownAiStateActor : AActor
{
	UPROPERTY()
	int CountdownValue = 0;

	UPROPERTY()
	bool bPromptVisible = false;

	UPROPERTY()
	bool bPromptHiddenByTimer = false;

	UPROPERTY()
	bool bCanAttack = false;

	UPROPERTY()
	bool bAlertState = false;

	UPROPERTY()
	bool bCountdownTimerCleared = false;

	UPROPERTY()
	bool bPromptTimerActiveAfterSetup = false;

	UPROPERTY()
	bool bCountdownTimerActiveAfterSetup = false;

	UPROPERTY()
	bool bAttackGateTimerActiveAfterSetup = false;

	UPROPERTY()
	bool bAlertStateTimerActiveAfterSetup = false;

	FTimerHandle PromptHandle;
	FTimerHandle CountdownHandle;
	FTimerHandle AttackGateHandle;
	FTimerHandle AlertStateHandle;

	UFUNCTION()
	void HidePrompt()
	{
		bPromptVisible = false;
		bPromptHiddenByTimer = true;
	}

	UFUNCTION()
	void AdvanceCountdown()
	{
		CountdownValue -= 1;
		if (CountdownValue <= 0)
		{
			CountdownValue = 0;
			System::ClearAndInvalidateTimerHandle(CountdownHandle);
			bCountdownTimerCleared = !SystemLibrary::TimerExistsHandle(CountdownHandle);
		}
	}

	UFUNCTION()
	void UnlockAttack()
	{
		bCanAttack = true;
	}

	UFUNCTION()
	void EnterAlertState()
	{
		bAlertState = true;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		bPromptVisible = true;
		CountdownValue = 3;
		bCanAttack = false;
		bAlertState = false;

		PromptHandle = System::SetTimer(this, n"HidePrompt", 0.1f, false);
		CountdownHandle = System::SetTimer(this, n"AdvanceCountdown", 0.1f, true);
		AttackGateHandle = System::SetTimer(this, n"UnlockAttack", 0.1f, false);
		AlertStateHandle = System::SetTimer(this, n"EnterAlertState", 0.2f, false);

		bPromptTimerActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(PromptHandle);
		bCountdownTimerActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(CountdownHandle);
		bAttackGateTimerActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(AttackGateHandle);
		bAlertStateTimerActiveAfterSetup = SystemLibrary::IsTimerActiveHandle(AlertStateHandle);
	}
}

bool Observe_UiCountdownAi_DefaultEmpty(ACoverageTimerUiCountdownAiStateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerUiCountdownAndAiStatePatterns setup: required Actor is null");
	}
	return Actor.CountdownValue == 0
		&& Actor.bPromptVisible == false
		&& Actor.bPromptHiddenByTimer == false
		&& Actor.bCanAttack == false
		&& Actor.bAlertState == false
		&& Actor.bCountdownTimerCleared == false
		&& Actor.bPromptTimerActiveAfterSetup == false
		&& Actor.bCountdownTimerActiveAfterSetup == false
		&& Actor.bAttackGateTimerActiveAfterSetup == false
		&& Actor.bAlertStateTimerActiveAfterSetup == false;
}

bool Observe_UiCountdownAi_HidePromptAndUnlock(ACoverageTimerUiCountdownAiStateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerUiCountdownAndAiStatePatterns setup: required Actor is null");
	}
	Actor.bPromptVisible = true;
	Actor.HidePrompt();
	Actor.UnlockAttack();
	Actor.EnterAlertState();
	return Actor.bPromptVisible == false
		&& Actor.bPromptHiddenByTimer == true
		&& Actor.bCanAttack == true
		&& Actor.bAlertState == true;
}

bool Observe_UiCountdownAi_AdvanceCountdownClampsZero(ACoverageTimerUiCountdownAiStateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerUiCountdownAndAiStatePatterns setup: required Actor is null");
	}
	Actor.CountdownValue = 1;
	Actor.AdvanceCountdown();
	return Actor.CountdownValue == 0;
}
