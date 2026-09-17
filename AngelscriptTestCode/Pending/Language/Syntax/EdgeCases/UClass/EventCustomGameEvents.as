/**
 * @version v1
 * @summary Custom game events modelling health and death. Two damage calls drain the health pool to zero, firing the health-changed event twice and the death and state-changed events once.
 * @topic Language
 */
/**
 * @version root
 * @summary Custom game events modelling health and death. Two damage calls drain the health pool to zero, firing the health-changed event twice and the death and state-changed events once.
 * @topic Baseline
 */
/**
 * Fires whenever the health pool changes value.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the previous and current health
 * @Return nothing when broadcast
 */
event void FCoverageHealthChangedEvent(float OldHealth, float NewHealth);

/**
 * Fires once when health reaches zero.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageDeathEvent();

/**
 * Fires when the alive/dead state flips.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the new state
 * @Return nothing when broadcast
 */
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

	FCoverageHealthChangedEvent OnHealthChanged;
	FCoverageDeathEvent OnDeath;
	FCoverageStateChangedEvent OnStateChanged;

	/**
	 * Binds the three handlers and applies two damage hits.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the events record the damage sequence
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnHealthChanged.AddUFunction(this, n"HandleHealthChanged");
		OnDeath.AddUFunction(this, n"HandleDeath");
		OnStateChanged.AddUFunction(this, n"HandleStateChanged");

		TakeDamage(30.0f);
		TakeDamage(70.0f); // Should trigger death
	}

	/**
	 * Applies damage and fires the health-changed and death events.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the damage amount
	 * @Return nothing; health decreases and death fires when it hits zero
	 * @Param Damage the damage to apply
	 */
	void TakeDamage(float Damage)
	{
		float OldHealth = Health;
		Health -= Damage;

		if (Health < 0.0f)
		{
			Health = 0.0f;
		}

		OnHealthChanged.Broadcast(OldHealth, Health);

		if (Health <= 0.0f && !IsDead)
		{
			IsDead = true;
			OnDeath.Broadcast();
			OnStateChanged.Broadcast(true);
		}
	}

	/**
	 * Records each health change.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the previous and current health
	 * @Return nothing; the counter gains 1 and the last values update
	 * @Param OldHealth the health before the change
	 * @Param NewHealth the health after the change
	 */
	UFUNCTION()
	void HandleHealthChanged(float OldHealth, float NewHealth)
	{
		HealthChangeCount++;
		LastOldHealth = OldHealth;
		LastNewHealth = NewHealth;
	}

	/**
	 * Records the death event.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 1
	 */
	UFUNCTION()
	void HandleDeath()
	{
		DeathEventCount++;
	}

	/**
	 * Receives state changes; the body is intentionally empty.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the new alive/dead state
	 * @Return nothing
	 * @Param NewState the state after the change
	 */
	UFUNCTION()
	void HandleStateChanged(bool NewState)
	{
	}

	/**
	 * Observe that a locally constructed actor is alive and untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when health is 100, alive, and no events counted
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool CustomGameActorDefaultsToAlive()
	{
		if (!Math::IsNearlyEqual(Health, 100.0))
		{
			return false;
		}

		if (IsDead)
		{
			return false;
		}

		if (HealthChangeCount != 0)
		{
			return false;
		}

		return DeathEventCount == 0;
	}

	/**
	 * Observe the recorded events after the damage sequence.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then the state and counters
	 * @Return true when both counts, the death flag and the final health match
	 */
	UFUNCTION()
	bool CustomGameEventsFireThroughDeath()
	{
		BeginPlay();

		if (HealthChangeCount != 2)
		{
			return false;
		}

		if (DeathEventCount != 1)
		{
			return false;
		}

		if (!IsDead)
		{
			return false;
		}

		return Math::IsNearlyEqual(Health, 0.0);
	}
}
/** @end */
