/**
 * A Client Unreliable RPC declaration on a replicating actor. C++ compiles the class
 * and checks that ClientUnreliableUpdate carries FUNC_NetClient without FUNC_NetReliable,
 * so those names are part of the contract and are kept verbatim. The observer covers a
 * default-constructed actor.
 *
 * @Theme Gameplay.Net
 * @Subject Net.UnreliableDeclarationCompiles
 * @Harness UClass
 * @Tag Gameplay.Net.UnreliableDeclarationCompiles
 * @Provenance Theme: Gameplay.Net. WorldStory Client Unreliable RPC compiles.
 * @Provenance C++: AngelscriptNetworkRPCTests.cpp::UnreliableDeclarationCompiles
 * @Provenance Oracle: compiles; ClientUnreliableUpdate carries FUNC_NetClient without FUNC_NetReliable.
 * @Provenance Extra: default-constructed actor. FixtureIsolated.
 */

UCLASS()
class AUnreliableRPCTestActor : AActor
{
	default SetReplicates(true);

	/**
	 * Client Unreliable RPC entrypoint whose flags C++ inspects.
	 *
	 * @Kind Observe
	 * @Covers Net.UnreliableDeclarationCompiles
	 * @Inputs none
	 * @Return nothing; the declaration is the contract
	 */
	UFUNCTION(Client, Unreliable)
	void ClientUnreliableUpdate()
	{
	}

	/**
	 * Observe that a default-constructed actor is non-null.
	 *
	 * @Kind Observe
	 * @Covers Net.UnreliableDeclarationCompiles
	 * @Inputs a locally constructed actor
	 * @Return true when the constructed actor is non-null
	 * @Boundary default-constructed actor
	 */
	UFUNCTION()
	bool DefaultConstructed()
	{
		AUnreliableRPCTestActor Actor;
		return Actor != nullptr;
	}
}
