// Theme: Gameplay.Physics. WorldStory simulate/gravity/mass/damping round-trip.
// C++: AngelscriptCoveragePhysicsTests.cpp::PhysicsSimulation
// Oracle VerifyByPath after BeginPlay: SimulatingPhysics true, GravityEnabled true, MassSet true,
// plus disabled-physics/gravity round-trip flags.
// Extra: defaults false / 0.0f. FixtureIsolated. Keep UPROPERTY names.

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
}

bool Observe_PhysicsSimulation_Defaults(ACoveragePhysicsSimulationActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PhysicsSimulation setup: required Actor is null");
	}
	return Actor.SimulatingPhysics == false
		&& Actor.GravityEnabled == false
		&& Actor.LinearDamping == 0.0f
		&& Actor.AngularDamping == 0.0f
		&& Actor.MassSet == false
		&& Actor.CenterOfMassSet == false
		&& Actor.PhysicsDisabledRoundTripped == false
		&& Actor.GravityDisabledRoundTripped == false
		&& Actor.LinearDampingSet == false
		&& Actor.AngularDampingSet == false;
}
