/**
 * @version v1
 * @summary A multicast event carrying a float health payload, stored on an actor. The member starts unbound; an unbound Broadcast is a no-op; two instances stay independent after a Broadcast on one of them.
 * @topic Feature
 */
/**
 * @version root
 * @summary A multicast event carrying a float health payload, stored on an actor. The member starts unbound; an unbound Broadcast is a no-op; two instances stay independent after a Broadcast on one of them.
 * @topic Baseline
 */
/**
 * A multicast event that reports a new health value.
 *
 * @Covers Delegates.Declaration
 * @Inputs NewHealth
 * @Return nothing when broadcast
 */
event void FOnHealthChanged(float NewHealth);

class ADelDeclEventActor : AActor
{
	UPROPERTY()
	FOnHealthChanged OnHealthChanged;
}

namespace DelegatesTest
{
	/**
	 * Observe that a freshly constructed actor's OnHealthChanged is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Param Actor the actor that holds OnHealthChanged, runner-owned when non-null
	 * @Inputs a locally constructed actor
	 * @Return true when OnHealthChanged is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool EventMulticastDefaultUnbound(ADelDeclEventActor Actor)
	{
		if (Actor is null)
		{
			throw("EventMulticast setup: required Actor is null");
		}
		return !Actor.OnHealthChanged.IsBound();
	}

	/**
	 * Observe that broadcasting 0.0 on an unbound event is a no-op.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Param Actor the actor that holds OnHealthChanged, runner-owned when non-null
	 * @Inputs Broadcast(0.0)
	 * @Return nothing; the event stays unbound
	 * @Boundary empty broadcast
	 */
	UFUNCTION()
	void EventMulticastEmptyBroadcastNoOp(ADelDeclEventActor Actor)
	{
		if (Actor is null)
		{
			throw("EventMulticast setup: required Actor is null");
		}
		Actor.OnHealthChanged.Broadcast(0.0);
	}

	/**
	 * Observe that broadcasting on one actor leaves the other unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Param First the actor that broadcasts, runner-owned when non-null
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs Broadcast(1.0) on First
	 * @Return true when both stay unbound
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool EventMulticastTwoLocalsIndependent(ADelDeclEventActor First, ADelDeclEventActor Second)
	{
		if (First is null)
		{
			throw("EventMulticast setup: required First is null");
		}
		if (Second is null)
		{
			throw("EventMulticast setup: required Second is null");
		}
		First.OnHealthChanged.Broadcast(1.0);
		if (First.OnHealthChanged.IsBound())
		{
			return false;
		}
		return !Second.OnHealthChanged.IsBound();
	}
}
/** @end */
