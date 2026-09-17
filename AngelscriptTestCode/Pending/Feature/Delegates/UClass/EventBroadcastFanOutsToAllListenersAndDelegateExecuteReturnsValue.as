/**
 * @version v1
 * @summary Multicast fan-out plus unicast Execute. After BeginPlay, ListenerOneCount is 2, ListenerTwoCount is 1, LastDamage is 7.0, DelegateWasBound is true, and LastCanInteractResult is true. ResolveCanInteract(0) is the false.
 * @topic Feature
 */
/**
 * @version root
 * @summary Multicast fan-out plus unicast Execute. After BeginPlay, ListenerOneCount is 2, ListenerTwoCount is 1, LastDamage is 7.0, DelegateWasBound is true, and LastCanInteractResult is true. ResolveCanInteract(0) is the false.
 * @topic Baseline
 */
/**
 * A multicast event that reports damage, a crit flag, and an origin.
 *
 * @Covers Delegates.Broadcast
 * @Inputs Damage, bWasCrit, and Origin
 * @Return nothing when broadcast
 */
event void FFunctionalDamageEvent(float Damage, bool bWasCrit, FVector Origin);

/**
 * A unicast that answers whether a querier can interact.
 *
 * @Covers Delegates.Execute
 * @Inputs Querier
 * @Return the bound handler's bool
 */
delegate bool FFunctionalCanInteract(int32 Querier);

UCLASS()
class AFunctionalBroadcastActor : AActor
{
	UPROPERTY()
	int32 ListenerOneCount = 0;

	UPROPERTY()
	int32 ListenerTwoCount = 0;

	UPROPERTY()
	float LastDamage = 0.0;

	UPROPERTY()
	bool LastCanInteractResult = false;

	UPROPERTY()
	bool DelegateWasBound = false;

	UPROPERTY()
	FFunctionalDamageEvent DamageEvent;

	UPROPERTY()
	FFunctionalCanInteract CanInteract;

	/**
	 * Records damage on listener one.
	 *
	 * @Covers Delegates.Broadcast
	 * @Param Damage the payload
	 * @Param bWasCrit the crit flag
	 * @Param Origin the origin
	 * @Inputs Damage, bWasCrit, and Origin
	 * @Return nothing; ListenerOneCount and LastDamage are written
	 */
	UFUNCTION()
	void HandleDamageOne(float Damage, bool bWasCrit, FVector Origin)
	{
		ListenerOneCount += 1;
		LastDamage = Damage;
	}

	/**
	 * Records listener two.
	 *
	 * @Covers Delegates.Broadcast
	 * @Param Damage the payload
	 * @Param bWasCrit the crit flag
	 * @Param Origin the origin
	 * @Inputs Damage, bWasCrit, and Origin
	 * @Return nothing; ListenerTwoCount gains 1
	 */
	UFUNCTION()
	void HandleDamageTwo(float Damage, bool bWasCrit, FVector Origin)
	{
		ListenerTwoCount += 1;
	}

	/**
	 * Returns true when Querier is greater than 0.
	 *
	 * @Covers Delegates.Execute
	 * @Param Querier the query id
	 * @Inputs Querier
	 * @Return Querier > 0
	 */
	UFUNCTION()
	bool ResolveCanInteract(int32 Querier)
	{
		return Querier > 0;
	}

	/**
	 * Binds both damage listeners, broadcasts, unbinds two, broadcasts again, then executes CanInteract.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Broadcast
	 * @Inputs none
	 * @Return nothing; the counts and LastCanInteractResult record the path
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		DamageEvent.AddUFunction(this, n"HandleDamageOne");
		DamageEvent.AddUFunction(this, n"HandleDamageTwo");
		DamageEvent.Broadcast(42.0, false, FVector(1.0, 2.0, 3.0));

		DamageEvent.Unbind(this, n"HandleDamageTwo");
		DamageEvent.Broadcast(7.0, true, FVector::ZeroVector);

		CanInteract.BindUFunction(this, n"ResolveCanInteract");
		DelegateWasBound = CanInteract.IsBound();
		LastCanInteractResult = CanInteract.Execute(3);
	}

	/**
	 * Observe the default fan-out state.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs this
	 * @Return true when counts are 0, flags are false, and both delegates are unbound
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ListenerOneCount != 0)
		{
			return false;
		}
		if (ListenerTwoCount != 0)
		{
			return false;
		}
		if (LastDamage != 0.0)
		{
			return false;
		}
		if (LastCanInteractResult)
		{
			return false;
		}
		if (DelegateWasBound)
		{
			return false;
		}
		if (DamageEvent.IsBound())
		{
			return false;
		}
		return !CanInteract.IsBound();
	}

	/**
	 * Observe ResolveCanInteract at zero, negative, and positive.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs ResolveCanInteract(0), (-1), and (3)
	 * @Return true when 0 and -1 are false and 3 is true
	 * @Boundary zero querier
	 */
	UFUNCTION()
	bool ResolveCanInteractFalseZeroBoundary()
	{
		if (ResolveCanInteract(0))
		{
			return false;
		}
		if (ResolveCanInteract(-1))
		{
			return false;
		}
		return ResolveCanInteract(3);
	}

	/**
	 * Observe a zero-damage write through listener one.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs HandleDamageOne(0.0, false, ZeroVector)
	 * @Return ListenerOneCount after the write
	 * @Boundary zero damage
	 */
	UFUNCTION()
	int HandleDamageOneZeroDamageBoundary()
	{
		HandleDamageOne(0.0, false, FVector::ZeroVector);
		return ListenerOneCount;
	}
}
/** @end */
