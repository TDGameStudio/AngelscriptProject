// Theme: Language.Syntax.EdgeCases. WorldStory health/death custom events.
// C++: AngelscriptCoverageEventTests.cpp::EventCustomGameEvents
// sha256=0b8b7fd1d318b94d5a00149b0f4527fec669c6d8e9e317fdf85a6b29392ac8b8; lines 1073-1159.
// Oracle after TakeDamage(30) then TakeDamage(70): HealthChangeCount=2, DeathEventCount=1,
// IsDead=true, Health=0.0. Extra: pre-play Health=100 and IsDead=false. FixtureIsolated.

event void FCoverageHealthChangedEvent(float OldHealth, float NewHealth);
event void FCoverageDeathEvent();
event void FCoverageStateChangedEvent(bool NewState);

UCLASS()
class ACoverageEventCustomGameActor : AActor
{
	UPROPERTY()
	float Health = 100.0f;

	UPROPERTY()
	bool IsDead = false;

	UPROPERTY()
	int HealthChangeCount = 0;

	UPROPERTY()
	int DeathEventCount = 0;

	UPROPERTY()
	float LastOldHealth = 0.0f;

	UPROPERTY()
	float LastNewHealth = 0.0f;

	// Custom game events
	FCoverageHealthChangedEvent OnHealthChanged;
	FCoverageDeathEvent OnDeath;
	FCoverageStateChangedEvent OnStateChanged;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Bind custom event handlers
		OnHealthChanged.AddUFunction(this, n"HandleHealthChanged");
		OnDeath.AddUFunction(this, n"HandleDeath");
		OnStateChanged.AddUFunction(this, n"HandleStateChanged");

		// Simulate game events
		TakeDamage(30.0f);
		TakeDamage(70.0f); // Should trigger death
	}

	void TakeDamage(float Damage)
	{
		float OldHealth = Health;
		Health -= Damage;

		if (Health < 0.0f)
		{
			Health = 0.0f;
		}

		// Broadcast health changed event
		OnHealthChanged.Broadcast(OldHealth, Health);

		// Check for death
		if (Health <= 0.0f && !IsDead)
		{
			IsDead = true;
			OnDeath.Broadcast();
			OnStateChanged.Broadcast(true);
		}
	}

	UFUNCTION()
	void HandleHealthChanged(float OldHealth, float NewHealth)
	{
		HealthChangeCount++;
		LastOldHealth = OldHealth;
		LastNewHealth = NewHealth;
	}

	UFUNCTION()
	void HandleDeath()
	{
		DeathEventCount++;
	}

	UFUNCTION()
	void HandleStateChanged(bool NewState)
	{
		// State change handler
	}
}

bool Observe_EventCustomGame_DefaultAlive(ACoverageEventCustomGameActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventCustomGameEvents setup: required Actor is null");
	}
	return Math::IsNearlyEqual(Actor.Health, 100.0) && !Actor.IsDead && Actor.HealthChangeCount == 0 && Actor.DeathEventCount == 0;
}
