// Theme: Gameplay.Timer. C++ compiles then VerifyByPath bHealthCheckActive.
// CSV NegativeDiagnostic; method is a periodic-timer oracle, not a compile-fail.
// C++: AngelscriptCoverageTimerTests.cpp::TimerUseCasePeriodicCheck
// Oracle after BeginPlay: bHealthCheckActive true.
// Extra: CheckCount 0, CurrentHealth 100.0, bHealthCheckActive false.
// CheckHealth at health 0 clears the handle. Do not spawn from script.

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerUseCasePeriodicCheck: Periodic health monitoring");

		// Check health every second
		HealthCheckHandle = System::SetTimer(this, n"CheckHealth", 1.0f, true);
		bHealthCheckActive = SystemLibrary::IsTimerActiveHandle(HealthCheckHandle);

		Print("Health check timer started (1.0s interval)");
	}
}

bool Observe_PeriodicCheck_DefaultEmpty(ACoverageTimerPeriodicCheckActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerUseCasePeriodicCheck setup: required Actor is null");
	}
	return Actor.CheckCount == 0
		&& Actor.CurrentHealth == 100.0f
		&& Actor.bHealthCheckActive == false;
}

bool Observe_PeriodicCheck_ZeroHealthStops(ACoverageTimerPeriodicCheckActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TimerUseCasePeriodicCheck setup: required Actor is null");
	}
	Actor.CurrentHealth = 0.0f;
	Actor.bHealthCheckActive = true;
	Actor.CheckHealth();
	return Actor.CheckCount == 1
		&& Actor.CurrentHealth == 0.0f
		&& Actor.bHealthCheckActive == false;
}
