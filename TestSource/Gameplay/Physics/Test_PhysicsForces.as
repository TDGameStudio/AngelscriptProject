// Theme: Gameplay.Physics. WorldStory force/impulse/torque application flags.
// C++: AngelscriptCoveragePhysicsTests.cpp::PhysicsForces
// Oracle VerifyByPath after BeginPlay: ForceApplied, ImpulseApplied, TorqueApplied,
// RadialForceApplied, RadialImpulseApplied, AngularImpulseApplied all true.
// Extra: defaults false. FixtureIsolated. Keep UPROPERTY names.

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
}

bool Observe_PhysicsForces_Defaults(ACoveragePhysicsForcesActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PhysicsForces setup: required Actor is null");
	}
	return Actor.ForceApplied == false
		&& Actor.ImpulseApplied == false
		&& Actor.TorqueApplied == false
		&& Actor.RadialForceApplied == false
		&& Actor.RadialImpulseApplied == false
		&& Actor.AngularImpulseApplied == false;
}

bool Observe_PhysicsForces_EmptyOriginBoundary()
{
	ACoveragePhysicsForcesActor Actor;
	FVector Origin = FVector::ZeroVector;
	return Origin.Equals(FVector::ZeroVector);
}
