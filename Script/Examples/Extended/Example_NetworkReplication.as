/**
 * Network replication basics example.
 *
 * AngelScript supports standard UE replication features for properties:
 * Replicated, ReplicatedUsing (RepNotify), and the default keyword
 * for setting bReplicates on actors.
 *
 * NOTE: RPC declarations (Server/Client/NetMulticast) require
 * preprocessor-level support that varies by plugin version.
 * This example focuses on the property replication patterns
 * that are stable across all versions.
 */

class AExampleReplicatedActor : AActor
{
	default bReplicates = true;

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

	/* Apply damage locally (for demonstration).
	 * In a real networked game, damage would be applied through
	 * server-authoritative logic. */
	UFUNCTION()
	void ApplyDamage(float DamageAmount)
	{
		Health = Math::Max(Health - DamageAmount, 0.0);
		Score += 1;
		Log(f"Applied {DamageAmount} damage, health now {Health}, score {Score}");
	}
};
