/**
 * @version v1
 * @summary A periodic health-check SetTimer pattern. C++ compiles then verifies bHealthCheckActive after BeginPlay, so those UPROPERTY names are part of the contract and are kept verbatim. CSV NegativeDiagnostic is a heuristic.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary A periodic health-check SetTimer pattern. C++ compiles then verifies bHealthCheckActive after BeginPlay, so those UPROPERTY names are part of the contract and are kept verbatim. CSV NegativeDiagnostic is a heuristic.
 * @topic Baseline
 */
UCLASS()
class ACoverageTimerPeriodicCheckActor : AActor
{
	UPROPERTY()
	int CheckCount = 0;

	UPROPERTY()
	float CurrentHealth = 100.0f;

	UPROPERTY()
	bool bHealthCheckActive = false;

	FTimerHandle HealthCheckHandle;

	/**
	 * Run one health check and stop the timer when health is depleted.
	 *
	 * @Kind Action
	 * @Covers Timer.TimerUseCasePeriodicCheck
	 * @Inputs none
	 * @Return CheckCount incremented; handle cleared when health is 0
	 */
	UFUNCTION()
	void CheckHealth()
	{
		CheckCount++;
		Print("Health check #" + CheckCount + ", current health: " + CurrentHealth);

		if (CurrentHealth <= 0.0f)
		{
			Print("Health depleted, stopping health check");
			System::ClearAndInvalidateTimerHandle(HealthCheckHandle);
			bHealthCheckActive = false;
		}
	}

	/**
	 * WorldStory: BeginPlay starts a looping health-check timer.
	 *
	 * @Kind WorldStory
	 * @Covers Timer.TimerUseCasePeriodicCheck
	 * @Inputs none
	 * @Return HealthCheckHandle armed and bHealthCheckActive true when the timer is active
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerUseCasePeriodicCheck: Periodic health monitoring");

		HealthCheckHandle = System::SetTimer(this, n"CheckHealth", 1.0f, true);
		bHealthCheckActive = SystemLibrary::IsTimerActiveHandle(HealthCheckHandle);

		Print("Health check timer started (1.0s interval)");
	}

	/**
	 * Observe that an untouched actor holds the empty health-check defaults.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerUseCasePeriodicCheck
	 * @Inputs none
	 * @Return true when count is 0, health is 100 and the check is inactive
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (CheckCount != 0)
		{
			return false;
		}
		if (CurrentHealth != 100.0f)
		{
			return false;
		}
		return bHealthCheckActive == false;
	}

	/**
	 * Observe that CheckHealth at zero health stops the looping timer.
	 *
	 * @Kind Observe
	 * @Covers Timer.TimerUseCasePeriodicCheck
	 * @Inputs none
	 * @Return true when count is 1, health is 0 and the check is inactive
	 * @Boundary zero health
	 */
	UFUNCTION()
	bool ZeroHealthStops()
	{
		CurrentHealth = 0.0f;
		bHealthCheckActive = true;
		CheckHealth();

		if (CheckCount != 1)
		{
			return false;
		}
		if (CurrentHealth != 0.0f)
		{
			return false;
		}
		return bHealthCheckActive == false;
	}
}
/** @end */
