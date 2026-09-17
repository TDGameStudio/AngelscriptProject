/**
 * @version v1
 * @summary Force, impulse, torque, radial force, radial impulse and angular impulse applied to a simulating sphere. C++ verifies the six flags by path after BeginPlay, so those UPROPERTY names are part of the contract and are kept.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Force, impulse, torque, radial force, radial impulse and angular impulse applied to a simulating sphere. C++ verifies the six flags by path after BeginPlay, so those UPROPERTY names are part of the contract and are kept.
 * @topic Baseline
 */
UCLASS()
class ACoveragePhysicsForcesActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool ForceApplied = false;

	UPROPERTY()
	bool ImpulseApplied = false;

	UPROPERTY()
	bool TorqueApplied = false;

	UPROPERTY()
	bool RadialForceApplied = false;

	UPROPERTY()
	bool RadialImpulseApplied = false;

	UPROPERTY()
	bool AngularImpulseApplied = false;

	/**
	 * WorldStory: BeginPlay enables simulation, then applies force, impulse, torque,
	 * radial force, radial impulse and angular impulse.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.PhysicsForces
	 * @Inputs a default-attached USphereComponent
	 * @Return ForceApplied, ImpulseApplied, TorqueApplied, RadialForceApplied,
	 * RadialImpulseApplied and AngularImpulseApplied true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Sphere.SetSimulatePhysics(true);

		// Add force
		Sphere.AddForce(FVector(0, 0, 1000), NAME_None, false);
		ForceApplied = true;

		// Add impulse
		Sphere.AddImpulse(FVector(100, 0, 0), NAME_None, false);
		ImpulseApplied = true;

		// Add torque
		Sphere.AddTorqueInDegrees(FVector(0, 0, 90), NAME_None, false);
		TorqueApplied = true;

		// Add radial force
		FVector Origin = GetActorLocation();
		Sphere.AddRadialForce(Origin, 500.0f, 1000.0f, ERadialImpulseFalloff::RIF_Linear, false);
		RadialForceApplied = true;

		// Add radial impulse
		Sphere.AddRadialImpulse(Origin, 500.0f, 250.0f, ERadialImpulseFalloff::RIF_Constant, false);
		RadialImpulseApplied = true;

		// Add angular impulse
		Sphere.AddAngularImpulseInDegrees(FVector(0, 45, 0), NAME_None, false);
		AngularImpulseApplied = true;
	}

	/**
	 * Observe that a locally constructed actor holds every flag false.
	 *
	 * @Kind Observe
	 * @Covers Physics.PhysicsForces
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when ForceApplied, ImpulseApplied, TorqueApplied, RadialForceApplied,
	 * RadialImpulseApplied and AngularImpulseApplied are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (ForceApplied)
		{
			return false;
		}
		if (ImpulseApplied)
		{
			return false;
		}
		if (TorqueApplied)
		{
			return false;
		}
		if (RadialForceApplied)
		{
			return false;
		}
		if (RadialImpulseApplied)
		{
			return false;
		}
		return AngularImpulseApplied == false;
	}

	/**
	 * Observe that a zero origin equals the zero vector.
	 *
	 * @Kind Observe
	 * @Covers Physics.PhysicsForces
	 * @Inputs FVector::ZeroVector
	 * @Return true when the origin equals the zero vector
	 * @Boundary empty origin
	 */
	UFUNCTION()
	bool EmptyOriginBoundary()
	{
		FVector Origin = FVector::ZeroVector;
		return Origin.Equals(FVector::ZeroVector);
	}
}
/** @end */
