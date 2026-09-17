/**
 * @version v1
 * @summary Physics simulation, gravity, an impulse and a force applied to a sphere component. C++ verifies the four flags by path. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary Physics simulation, gravity, an impulse and a force applied to a sphere component. C++ verifies the four flags by path. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
UCLASS()
class ACoveragePrimitivePhysicsActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	bool PhysicsEnabled = false;

	UPROPERTY()
	bool GravityEnabled = false;

	UPROPERTY()
	bool ImpulseApplied = false;

	UPROPERTY()
	bool ForceApplied = false;

	/**
	 * WorldStory: BeginPlay enables simulation and gravity, then applies an impulse
	 * and a force.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitivePhysics
	 * @Inputs a default-attached USphereComponent
	 * @Return all four flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);

		// Enable physics simulation
		SphereComp.SetSimulatePhysics(true);
		PhysicsEnabled = SphereComp.IsSimulatingPhysics();

		// Enable gravity
		SphereComp.SetEnableGravity(true);
		GravityEnabled = SphereComp.IsGravityEnabled();

		// Apply impulse
		SphereComp.AddImpulse(FVector(0.0f, 0.0f, 1000.0f), NAME_None, false);
		ImpulseApplied = true;

		// Apply force
		SphereComp.AddForce(FVector(0.0f, 0.0f, 500.0f), NAME_None, false);
		ForceApplied = true;
	}

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitivePhysics
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all four flags are clear and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (PhysicsEnabled)
		{
			return false;
		}
		if (GravityEnabled)
		{
			return false;
		}
		if (ImpulseApplied)
		{
			return false;
		}
		if (ForceApplied)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitivePhysics
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both flags and the other stays clear
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitivePhysicsActor Second)
	{
		if (Second is null)
		{
			throw("PrimitivePhysics setup: required Second is null");
		}
		PhysicsEnabled = true;
		ImpulseApplied = true;

		if (!PhysicsEnabled)
		{
			return false;
		}
		if (!ImpulseApplied)
		{
			return false;
		}
		if (Second.PhysicsEnabled)
		{
			return false;
		}
		return !Second.ImpulseApplied;
	}
}
/** @end */
