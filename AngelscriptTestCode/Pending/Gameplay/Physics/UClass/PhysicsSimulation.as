/**
 * @version v1
 * @summary Simulate, gravity, mass, center of mass and damping round-trips on a sphere. C++ verifies the flags by path after BeginPlay, so those UPROPERTY names are part of the contract and are kept verbatim. The observer covers.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Simulate, gravity, mass, center of mass and damping round-trips on a sphere. C++ verifies the flags by path after BeginPlay, so those UPROPERTY names are part of the contract and are kept verbatim. The observer covers.
 * @topic Baseline
 */
UCLASS()
class ACoveragePhysicsSimulationActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool SimulatingPhysics = false;

	UPROPERTY()
	bool GravityEnabled = false;

	UPROPERTY()
	float LinearDamping = 0.0f;

	UPROPERTY()
	float AngularDamping = 0.0f;

	UPROPERTY()
	bool MassSet = false;

	UPROPERTY()
	bool CenterOfMassSet = false;

	UPROPERTY()
	bool PhysicsDisabledRoundTripped = false;

	UPROPERTY()
	bool GravityDisabledRoundTripped = false;

	UPROPERTY()
	bool LinearDampingSet = false;

	UPROPERTY()
	bool AngularDampingSet = false;

	/**
	 * WorldStory: BeginPlay enables simulation and gravity, writes damping, mass and
	 * center of mass, then disables physics and gravity and reads each back.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.PhysicsSimulation
	 * @Inputs a default-attached USphereComponent
	 * @Return SimulatingPhysics, GravityEnabled, MassSet and the disabled-physics/gravity
	 * round-trip flags true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Sphere.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);

		// Enable physics simulation
		Sphere.SetSimulatePhysics(true);
		SimulatingPhysics = Sphere.IsSimulatingPhysics();

		// Enable gravity
		Sphere.SetEnableGravity(true);
		GravityEnabled = Sphere.IsGravityEnabled();

		// Set damping
		Sphere.SetLinearDamping(0.5f);
		LinearDamping = Sphere.GetLinearDamping();
		LinearDampingSet = (LinearDamping > 0.49f && LinearDamping < 0.51f);

		Sphere.SetAngularDamping(0.3f);
		AngularDamping = Sphere.GetAngularDamping();
		AngularDampingSet = (AngularDamping > 0.29f && AngularDamping < 0.31f);

		// Set mass
		Sphere.SetMassOverrideInKg(NAME_None, 100.0f, true);
		MassSet = (Sphere.GetMass() > 99.0f);

		// Set center of mass offset
		Sphere.SetCenterOfMass(FVector(1.0f, 2.0f, 3.0f), NAME_None);
		CenterOfMassSet = true;

		// Boundary state: disabled physics and gravity should also round-trip.
		Sphere.SetSimulatePhysics(false);
		PhysicsDisabledRoundTripped = !Sphere.IsSimulatingPhysics();
		Sphere.SetEnableGravity(false);
		GravityDisabledRoundTripped = !Sphere.IsGravityEnabled();
	}

	/**
	 * Observe that a locally constructed actor holds flags false and damping 0.
	 *
	 * @Kind Observe
	 * @Covers Physics.PhysicsSimulation
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when SimulatingPhysics, GravityEnabled, MassSet, CenterOfMassSet,
	 * PhysicsDisabledRoundTripped, GravityDisabledRoundTripped, LinearDampingSet and
	 * AngularDampingSet are false and both damping values are 0.0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (SimulatingPhysics)
		{
			return false;
		}
		if (GravityEnabled)
		{
			return false;
		}
		if (LinearDamping != 0.0f)
		{
			return false;
		}
		if (AngularDamping != 0.0f)
		{
			return false;
		}
		if (MassSet)
		{
			return false;
		}
		if (CenterOfMassSet)
		{
			return false;
		}
		if (PhysicsDisabledRoundTripped)
		{
			return false;
		}
		if (GravityDisabledRoundTripped)
		{
			return false;
		}
		if (LinearDampingSet)
		{
			return false;
		}
		return AngularDampingSet == false;
	}
}
/** @end */
