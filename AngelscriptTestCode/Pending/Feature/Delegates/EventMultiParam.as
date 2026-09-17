/**
 * @version v1
 * @summary A multicast event with FString, int, and bool parameters, stored on an actor. The member starts unbound; an empty-string Broadcast is a no-op; two instances stay independent after a Broadcast on one of them.
 * @topic Feature
 */
/**
 * @version root
 * @summary A multicast event with FString, int, and bool parameters, stored on an actor. The member starts unbound; an empty-string Broadcast is a no-op; two instances stay independent after a Broadcast on one of them.
 * @topic Baseline
 */
/**
 * A multicast event carrying a name, a data integer, and an importance flag.
 *
 * @Covers Delegates.Declaration
 * @Inputs EventName, Data, and bImportant
 * @Return nothing when broadcast
 */
event void FOnGameEvent(FString EventName, int Data, bool bImportant);

class ADelDeclEventMultiActor : AActor
{
	UPROPERTY()
	FOnGameEvent OnGameEvent;
}

namespace DelegatesTest
{
	/**
	 * Observe that a freshly constructed actor's OnGameEvent is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Param Actor the actor that holds OnGameEvent, runner-owned when non-null
	 * @Inputs a locally constructed actor
	 * @Return true when OnGameEvent is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool EventMultiParamDefaultUnbound(ADelDeclEventMultiActor Actor)
	{
		if (Actor is null)
		{
			throw("EventMultiParam setup: required Actor is null");
		}
		return !Actor.OnGameEvent.IsBound();
	}

	/**
	 * Observe that broadcasting empty values on an unbound event is a no-op.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Param Actor the actor that holds OnGameEvent, runner-owned when non-null
	 * @Inputs Broadcast("", 0, false)
	 * @Return nothing; the event stays unbound
	 * @Boundary empty broadcast
	 */
	UFUNCTION()
	void EventMultiParamEmptyBroadcastNoOp(ADelDeclEventMultiActor Actor)
	{
		if (Actor is null)
		{
			throw("EventMultiParam setup: required Actor is null");
		}
		Actor.OnGameEvent.Broadcast("", 0, false);
	}

	/**
	 * Observe that broadcasting on one actor leaves the other unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Param First the actor that broadcasts, runner-owned when non-null
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs Broadcast("Fire", 1, true) on First
	 * @Return true when both stay unbound
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool EventMultiParamTwoLocalsIndependent(ADelDeclEventMultiActor First, ADelDeclEventMultiActor Second)
	{
		if (First is null)
		{
			throw("EventMultiParam setup: required First is null");
		}
		if (Second is null)
		{
			throw("EventMultiParam setup: required Second is null");
		}
		First.OnGameEvent.Broadcast("Fire", 1, true);
		if (First.OnGameEvent.IsBound())
		{
			return false;
		}
		return !Second.OnGameEvent.IsBound();
	}
}
/** @end */
