/**
 * @version v1
 * @summary UI countdown and AI-state timer patterns on one actor. C++ compiles then verifies the setup flags by path, so those UPROPERTY names are part of the contract and are kept verbatim. CSV NegativeDiagnostic is a heuristic.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary UI countdown and AI-state timer patterns on one actor. C++ compiles then verifies the setup flags by path, so those UPROPERTY names are part of the contract and are kept verbatim. CSV NegativeDiagnostic is a heuristic.
 * @topic Baseline
 */
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

	/**
	 * Hide the prompt when its timer fires.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerUiCountdownAndAiStatePatterns
	 * @Inputs none
	 * @Return bPromptVisible false and bPromptHiddenByTimer true
	 */
	UFUNCTION()
	void HidePrompt()
	{
		bPromptVisible = false;
		bPromptHiddenByTimer = true;
	}

	/**
	 * Decrement the countdown and clear the looping timer at zero.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerUiCountdownAndAiStatePatterns
	 * @Inputs none
	 * @Return CountdownValue decremented, clamped at 0
	 */
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

	/**
	 * Unlock attacking when the gate timer fires.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerUiCountdownAndAiStatePatterns
	 * @Inputs none
	 * @Return bCanAttack true
	 */
	UFUNCTION()
	void UnlockAttack()
	{
		bCanAttack = true;
	}

	/**
	 * Enter the alert state when its timer fires.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerUiCountdownAndAiStatePatterns
	 * @Inputs none
	 * @Return bAlertState true
	 */
	UFUNCTION()
	void EnterAlertState()
	{
		bAlertState = true;
	}

	/**
	 * WorldStory: BeginPlay arms the four UI/AI timers and records whether each is active.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerUiCountdownAndAiStatePatterns
	 * @Inputs none
	 * @Return prompt visible, countdown 3, attack/alert false, four active flags true
	 */
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

	/**
	 * Observe that an untouched actor holds the empty UI/AI defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerUiCountdownAndAiStatePatterns
	 * @Inputs none
	 * @Return true when countdown, flags and active bits are 0/false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (CountdownValue != 0)
		{
			return false;
		}
		if (bPromptVisible != false)
		{
			return false;
		}
		if (bPromptHiddenByTimer != false)
		{
			return false;
		}
		if (bCanAttack != false)
		{
			return false;
		}
		if (bAlertState != false)
		{
			return false;
		}
		if (bCountdownTimerCleared != false)
		{
			return false;
		}
		if (bPromptTimerActiveAfterSetup != false)
		{
			return false;
		}
		if (bCountdownTimerActiveAfterSetup != false)
		{
			return false;
		}
		if (bAttackGateTimerActiveAfterSetup != false)
		{
			return false;
		}
		return bAlertStateTimerActiveAfterSetup == false;
	}

	/**
	 * Observe that HidePrompt, UnlockAttack and EnterAlertState mutate state without spawning.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerUiCountdownAndAiStatePatterns
	 * @Inputs none
	 * @Return true when prompt is hidden, attack is unlocked and alert is true
	 */
	UFUNCTION()
	bool HidePromptAndUnlock()
	{
		bPromptVisible = true;
		HidePrompt();
		UnlockAttack();
		EnterAlertState();

		if (bPromptVisible != false)
		{
			return false;
		}
		if (bPromptHiddenByTimer != true)
		{
			return false;
		}
		if (bCanAttack != true)
		{
			return false;
		}
		return bAlertState == true;
	}

	/**
	 * Observe that AdvanceCountdown clamps at zero.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerUiCountdownAndAiStatePatterns
	 * @Inputs none
	 * @Return true when CountdownValue is 0 after advancing from 1
	 * @Boundary zero
	 */
	UFUNCTION()
	bool AdvanceCountdownClampsZero()
	{
		CountdownValue = 1;
		AdvanceCountdown();
		return CountdownValue == 0;
	}
}
/** @end */
