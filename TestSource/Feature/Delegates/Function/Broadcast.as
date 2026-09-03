/**
 * Broadcast(42) on a multicast event. The event starts unbound; Fire on an
 * unbound event is a no-op; Broadcast(0) is the zero boundary; two instances
 * stay independent.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.Broadcast
 * @Harness Function
 * @Tag Feature.Delegates.Broadcast
 * @Namespace DelegatesTest
 * @Provenance Theme: Feature.Delegates. WorldStory Broadcast(42) on a multicast event.
 * @Provenance C++: AngelscriptSyntaxDelegateEventTests.cpp::Binding_Positive_Broadcast
 * @Provenance sha256 from theme-refs TS-FEAT-0346; lines 381-394.
 * @Provenance Oracle: AssertCompiles DelBindBroadcast. Extra: default unbound; Fire is a no-op;
 * @Provenance Broadcast 0 is the zero boundary. FixtureIsolated.
 */

/**
 * A multicast event that reports an integer value.
 *
 * @Covers Delegates.Binding
 * @Inputs Val
 * @Return nothing when broadcast
 */
event void FOnChangedBroadcast(int Val);

class ADelBroadcastActor : AActor
{
	UPROPERTY()
	FOnChangedBroadcast OnChanged;

	/**
	 * Broadcasts 42 on OnChanged.
	 *
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return nothing; an unbound Broadcast is a no-op
	 */
	void Fire()
	{
		OnChanged.Broadcast(42);
	}
}

namespace DelegatesTest
{
	/**
	 * Observe that a freshly constructed actor's OnChanged is unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param Actor the actor that holds OnChanged, runner-owned when non-null
	 * @Inputs a locally constructed actor
	 * @Return true when OnChanged is unbound
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool BroadcastDefaultUnbound(ADelBroadcastActor Actor)
	{
		if (Actor is null)
		{
			throw("Broadcast setup: required Actor is null");
		}
		return !Actor.OnChanged.IsBound();
	}

	/**
	 * Observe that Fire and Broadcast(0) on an unbound event are no-ops.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param Actor the actor that holds OnChanged, runner-owned when non-null
	 * @Inputs Fire() then Broadcast(0)
	 * @Return nothing; the event stays unbound
	 * @Boundary unbound fire
	 */
	UFUNCTION()
	void BroadcastUnboundFireIsNoOp(ADelBroadcastActor Actor)
	{
		if (Actor is null)
		{
			throw("Broadcast setup: required Actor is null");
		}
		Actor.Fire();
		Actor.OnChanged.Broadcast(0);
	}

	/**
	 * Observe that Fire on one actor leaves the other unbound.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Binding
	 * @Param First the actor that fires, runner-owned when non-null
	 * @Param Second the other actor, runner-owned when non-null
	 * @Inputs Fire on First
	 * @Return true when both stay unbound
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BroadcastTwoLocalsIndependent(ADelBroadcastActor First, ADelBroadcastActor Second)
	{
		if (First is null)
		{
			throw("Broadcast setup: required First is null");
		}
		if (Second is null)
		{
			throw("Broadcast setup: required Second is null");
		}
		First.Fire();
		if (First.OnChanged.IsBound())
		{
			return false;
		}
		return !Second.OnChanged.IsBound();
	}
}
