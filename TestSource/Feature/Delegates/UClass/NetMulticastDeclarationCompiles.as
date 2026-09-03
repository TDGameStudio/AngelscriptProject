/**
 * A NetMulticast RPC declaration. The class compiles and MulticastBroadcastEvent
 * carries FUNC_Net, FUNC_NetMulticast, and FUNC_NetReliable. An empty multicast
 * body is a no-op.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.NetMulticastDeclarationCompiles
 * @Harness UClass
 * @Tag Feature.Delegates.NetMulticastDeclarationCompiles
 * @Provenance Theme: Feature.Delegates. WorldStory NetMulticast RPC declaration.
 * @Provenance C++: AngelscriptNetworkRPCTests.cpp::NetMulticastDeclarationCompiles
 * @Provenance sha256=dc5b6537fea88d110d4bf2ad530cbbc30616363ddb6a0b1182fb43f2c8630985; lines 163-174.
 * @Provenance Oracle: class compiles; MulticastBroadcastEvent carries FUNC_Net|FUNC_NetMulticast|FUNC_NetReliable.
 * @Provenance Extra: local construct; empty multicast body is a no-op. FixtureIsolated.
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
