/**
 * @version v1
 * @summary A NetMulticast RPC declaration. The class compiles and MulticastBroadcastEvent carries FUNC_Net, FUNC_NetMulticast, and FUNC_NetReliable. An empty multicast body is a no-op.
 * @topic Feature
 */
/**
 * @version root
 * @summary A NetMulticast RPC declaration. The class compiles and MulticastBroadcastEvent carries FUNC_Net, FUNC_NetMulticast, and FUNC_NetReliable. An empty multicast body is a no-op.
 * @topic Baseline
 */
UCLASS()
class AMulticastRPCTestActor : AActor
{
	default SetReplicates(true);

	/**
	 * A reliable NetMulticast RPC with an empty body.
	 *
	 * @Covers Delegates.NetMulticast
	 * @Inputs none
	 * @Return nothing
	 */
	UFUNCTION(NetMulticast)
	void MulticastBroadcastEvent()
	{
	}

	/**
	 * Observe a local construct of the actor.
	 *
	 * @Kind Observe
	 * @Covers Delegates.NetMulticast
	 * @Inputs a local AMulticastRPCTestActor
	 * @Return nothing
	 * @Boundary local construct
	 */
	UFUNCTION()
	void LocalConstruct()
	{
		AMulticastRPCTestActor Actor;
	}

	/**
	 * Observe that calling the empty multicast body is a no-op.
	 *
	 * @Kind Observe
	 * @Covers Delegates.NetMulticast
	 * @Inputs MulticastBroadcastEvent()
	 * @Return nothing
	 * @Boundary empty call
	 */
	UFUNCTION()
	void EmptyCallIsNoOp()
	{
		MulticastBroadcastEvent();
	}

	/**
	 * Observe that a second local handle stays distinct after a multicast on this.
	 *
	 * @Kind Observe
	 * @Covers Delegates.NetMulticast
	 * @Inputs MulticastBroadcastEvent() then a second local
	 * @Return true when this and the second handle are non-null and differ
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool TwoLocalsIndependent()
	{
		AMulticastRPCTestActor Second;
		MulticastBroadcastEvent();
		if (this == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}
		return this != Second;
	}
}
/** @end */
