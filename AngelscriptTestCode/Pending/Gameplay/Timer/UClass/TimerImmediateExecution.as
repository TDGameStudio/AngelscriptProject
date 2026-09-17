/**
 * @version v1
 * @summary A short-delay single-shot timer whose remaining time is queried immediately after SetTimer. C++ verifies the setup and remaining-bound flags by path, so those UPROPERTY names are part of the contract and are kept.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A short-delay single-shot timer whose remaining time is queried immediately after SetTimer. C++ verifies the setup and remaining-bound flags by path, so those UPROPERTY names are part of the contract and are kept.
 * @topic Baseline
 */
UCLASS()
class ACoverageTimerImmediateExecutionActor : AActor
{
	UPROPERTY()
	bool bImmediateTimerSetup = false;

	UPROPERTY()
	float ImmediateRemaining = 0.0f;

	UPROPERTY()
	bool bImmediateRemainingIsBounded = false;

	UPROPERTY()
	int CallbackCount = 0;

	FTimerHandle ImmediateHandle;

	/**
	 * Count a short-delay single-shot callback.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerImmediateExecution
	 * @Inputs none
	 * @Return CallbackCount incremented once
	 */
	UFUNCTION()
	void ImmediateCallback()
	{
		CallbackCount++;
		Print("ImmediateCallback executed on next tick, count: " + CallbackCount);
	}

	/**
	 * WorldStory: BeginPlay sets a 0.001s single-shot timer and records remaining
	 * time immediately.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerImmediateExecution
	 * @Inputs none
	 * @Return bImmediateTimerSetup true and remaining bounded to the configured delay
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerImmediateExecution: Testing short-delay single-shot timer execution");

		ImmediateHandle = System::SetTimer(this, n"ImmediateCallback", 0.001f, false);

		bImmediateTimerSetup = SystemLibrary::IsTimerActiveHandle(ImmediateHandle);
		ImmediateRemaining = SystemLibrary::GetTimerRemainingTimeHandle(ImmediateHandle);
		bImmediateRemainingIsBounded = (ImmediateRemaining >= 0.0f && ImmediateRemaining <= 0.01f);

		Print("Immediate timer set, active: " + bImmediateTimerSetup);
		Print("Remaining: " + ImmediateRemaining + " seconds");
	}

	/**
	 * Observe that an untouched actor holds the empty defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerImmediateExecution
	 * @Inputs none
	 * @Return true when setup is false, remaining is 0 and CallbackCount is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (bImmediateTimerSetup != false)
		{
			return false;
		}
		if (ImmediateRemaining != 0.0f)
		{
			return false;
		}
		if (bImmediateRemainingIsBounded != false)
		{
			return false;
		}
		return CallbackCount == 0;
	}

	/**
	 * Observe that calling the callback directly increments the count.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerImmediateExecution
	 * @Inputs none
	 * @Return true when CallbackCount is 1
	 */
	UFUNCTION()
	bool DirectCallback()
	{
		ImmediateCallback();
		return CallbackCount == 1;
	}
}
/** @end */
