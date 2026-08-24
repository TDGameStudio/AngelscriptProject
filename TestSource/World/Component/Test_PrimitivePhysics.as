// Theme: World.Component. WorldStory: SetSimulatePhysics, SetEnableGravity,
// AddImpulse, AddForce.
// C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitivePhysics
// sha256=e86ab01bb09cb6cca0db49dfc9008fd9b1ed48f7b0915340793bd633d88ef449; lines 498-539.
// Oracle VerifyByPath PhysicsEnabled, GravityEnabled, ImpulseApplied,
// ForceApplied all true. Extra: local construct all false, SphereComp null.
// FixtureIsolated.

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
}

bool Observe_PrimitivePhysics_DefaultFalse(ACoveragePrimitivePhysicsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitivePhysics setup: required Actor is null");
	}
	return !Actor.PhysicsEnabled
		&& !Actor.GravityEnabled
		&& !Actor.ImpulseApplied
		&& !Actor.ForceApplied
		&& Actor.SphereComp == nullptr;
}

bool Observe_PrimitivePhysics_CopyIndependence(ACoveragePrimitivePhysicsActor First, ACoveragePrimitivePhysicsActor Second)
{
	if (First is null)
	{
		throw("Test_PrimitivePhysics setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PrimitivePhysics setup: required Second is null");
	}
	First.PhysicsEnabled = true;
	First.ImpulseApplied = true;
	return First.PhysicsEnabled
		&& First.ImpulseApplied
		&& !Second.PhysicsEnabled
		&& !Second.ImpulseApplied;
}
