/**
 * Network replication and RPC example.
 *
 * AngelScript supports standard UE replication features:
 *
 *   Property replication:
 *     - Replicated              — property is replicated to all clients
 *     - ReplicatedUsing=FuncName — property is replicated with a RepNotify callback
 *     - ReplicationCondition=X  — fine-grained replication condition (OwnerOnly, SkipReplay, etc.)
 *
 *   RPC (Remote Procedure Call) declarations:
 *     - Server                  — called on the client, executes on the server
 *     - Client                  — called on the server, executes on the owning client
 *     - NetMulticast            — called on the server, executes on server and all clients
 *     - WithValidation          — requires a _Validate() function that returns bool
 *     - Unreliable              — sent unreliably (may be dropped); default is Reliable
 *
 *   Specifier names: use Server/Client/NetMulticast (NOT NetServer/NetClient).
 */

// ============================================================================
// Property Replication Example
// ============================================================================

class AExampleReplicatedActor : AActor
{
	default SetReplicates(true);

	/* A replicated property: changes on the server are sent to all clients. */
	UPROPERTY(Replicated, Category = "Network")
	int Score = 0;

	/* A replicated property with a notify function.
	 * OnRep_Health is called on the client when the value changes. */
	UPROPERTY(ReplicatedUsing = OnRep_Health, Category = "Network")
	float Health = 100.0;

	/* A simple replicated counter. */
	UPROPERTY(Replicated, Category = "Network")
	int Ammo = 30;

	/* RepNotify handler: called on clients when Health changes. */
	UFUNCTION()
	void OnRep_Health()
	{
		Print(f"Health changed to: {Health}");

		if (Health <= 0.0)
		{
			Print("Actor has died on client!");
		}
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Log(f"ReplicatedActor BeginPlay - Score: {Score}, Health: {Health}, Ammo: {Ammo}");
	}
};

// ============================================================================
// RPC Declaration Example
// ============================================================================

/**
 * Demonstrates all RPC patterns available in AngelScript.
 *
 * Key rules:
 *   - The actor must call SetReplicates(true) in its defaults.
 *   - Server RPCs execute on the server when called from any client.
 *   - Client RPCs execute on the owning client when called from the server.
 *   - NetMulticast RPCs execute on the server and all connected clients.
 *   - WithValidation requires a sibling _Validate() function.
 *   - By default RPCs are Reliable; add Unreliable for non-critical calls.
 */
class AExampleRPCActor : AActor
{
	default SetReplicates(true);

	UPROPERTY(Replicated, Category = "Network")
	int DamageDealt = 0;

	// --- Server RPC: runs on server, called from client ---
	UFUNCTION(Server)
	void ServerRequestAttack()
	{
		DamageDealt += 10;
		Log(f"Server: Attack processed, total damage = {DamageDealt}");

		// After processing, notify the owning client
		ClientConfirmHit(DamageDealt);
	}

	// --- Client RPC: runs on owning client, called from server ---
	UFUNCTION(Client)
	void ClientConfirmHit(int TotalDamage)
	{
		Log(f"Client: Hit confirmed! Total damage = {TotalDamage}");
	}

	// --- NetMulticast RPC: runs on server + all clients ---
	UFUNCTION(NetMulticast, Unreliable)
	void MulticastPlayHitEffect()
	{
		Log("All: Playing hit visual effect");
	}

	// --- Server RPC with validation ---
	// The _Validate function must return true for the RPC to execute.
	UFUNCTION(Server, WithValidation)
	void ServerValidatedUseItem(int ItemId)
	{
		Log(f"Server: Item {ItemId} used (validated)");
	}

	UFUNCTION()
	bool ServerValidatedUseItem_Validate(int ItemId)
	{
		// Reject invalid item IDs as a basic cheat check
		return ItemId > 0 && ItemId < 1000;
	}
};
