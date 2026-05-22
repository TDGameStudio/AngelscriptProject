/**
 * Blueprint subclass example.
 *
 * Script classes can serve as base classes for Blueprint classes.
 * This allows you to define core logic in script while letting
 * designers customize visuals and parameters in Blueprint.
 */

/**
 * A script base class for a pickup item.
 * Designers can create Blueprint subclasses of this actor
 * and override the visual mesh, effects, and pickup behavior.
 */
class AExamplePickupBase : AActor
{
	UPROPERTY()
	USphereComponent CollisionSphere;

	/* The value this pickup gives to the player. Editable in Blueprint subclasses. */
	UPROPERTY(Category = "Pickup")
	int PickupValue = 10;

	/* Whether this pickup has been collected. */
	UPROPERTY(BlueprintReadOnly, Category = "Pickup")
	bool bCollected = false;

	default SetReplicates(true);

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (CollisionSphere != nullptr)
		{
			CollisionSphere.OnComponentBeginOverlap.AddUFunction(this, n"OnOverlapBegin");
		}
	}

	UFUNCTION()
	void OnOverlapBegin(
		UPrimitiveComponent OverlappedComponent, AActor OtherActor,
		UPrimitiveComponent OtherComponent, int OtherBodyIndex,
		bool bFromSweep, const FHitResult&in Hit)
	{
		if (!bCollected)
		{
			bCollected = true;
			OnPickedUp(OtherActor);
		}
	}

	/**
	 * Called when the pickup is collected.
	 * Blueprint subclasses can override this to add VFX, sounds, etc.
	 */
	UFUNCTION(BlueprintEvent)
	void OnPickedUp(AActor Collector)
	{
		Print(f"{Collector.GetName()} picked up {GetName()} (value: {PickupValue})");
	}
};

/**
 * A script-level specialization: a health pickup.
 * This can also be further subclassed in Blueprint.
 */
class AExampleHealthPickup : AExamplePickupBase
{
	UPROPERTY(Category = "Pickup")
	float HealAmount = 25.0;

	default PickupValue = 25;

	UFUNCTION(BlueprintOverride)
	void OnPickedUp(AActor Collector)
	{
		Print(f"{Collector.GetName()} healed for {HealAmount} HP");
	}
};
