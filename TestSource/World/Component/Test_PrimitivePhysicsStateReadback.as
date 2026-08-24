// Theme: World.Component. WorldStory: simulate/gravity/mass/velocity round-trip.
// C++: AngelscriptCoveragePrimitiveComponentTests.cpp::PrimitivePhysicsStateReadback
// sha256=1626893c3666732c7b1c79a7effbdf148f9ad3b3cbab787d758b9ae1bed7956d; lines 583-644.
// Oracle VerifyByPath SimulatePhysicsEnabled/Disabled, GravityDisabled,
// MassOverrideRoundTripped, LinearVelocityRoundTripped,
// AngularVelocityRoundTripped all true. Extra: local construct all false,
// SphereComp null. FixtureIsolated.

UCLASS()
class ACoveragePrimitivePhysicsStateReadbackActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent SphereComp;

	UPROPERTY()
	bool SimulatePhysicsEnabled = false;

	UPROPERTY()
	bool SimulatePhysicsDisabled = false;

	UPROPERTY()
	bool GravityDisabled = false;

	UPROPERTY()
	bool MassOverrideRoundTripped = false;

	UPROPERTY()
	bool LinearVelocityRoundTripped = false;

	UPROPERTY()
	bool AngularVelocityRoundTripped = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SphereComp.SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
		SphereComp.SetSimulatePhysics(true);
		SimulatePhysicsEnabled = SphereComp.IsSimulatingPhysics();

		SphereComp.SetEnableGravity(false);
		GravityDisabled = !SphereComp.IsGravityEnabled();

		SphereComp.SetMassOverrideInKg(NAME_None, 125.0f, true);
		float Mass = SphereComp.GetMass();
		MassOverrideRoundTripped = Mass > 124.0f && Mass < 126.0f;

		FVector TargetLinearVelocity = FVector(120.0f, 30.0f, 0.0f);
		SphereComp.SetPhysicsLinearVelocity(TargetLinearVelocity, false, NAME_None);
		FVector LinearVelocity = SphereComp.GetPhysicsLinearVelocity(NAME_None);
		LinearVelocityRoundTripped =
			LinearVelocity.X > 119.0f
			&& LinearVelocity.X < 121.0f
			&& LinearVelocity.Y > 29.0f
			&& LinearVelocity.Y < 31.0f;

		FVector TargetAngularVelocity = FVector(0.0f, 45.0f, 90.0f);
		SphereComp.SetPhysicsAngularVelocityInDegrees(TargetAngularVelocity, false, NAME_None);
		FVector AngularVelocity = SphereComp.GetPhysicsAngularVelocityInDegrees(NAME_None);
		AngularVelocityRoundTripped =
			AngularVelocity.Y > 44.0f
			&& AngularVelocity.Y < 46.0f
			&& AngularVelocity.Z > 89.0f
			&& AngularVelocity.Z < 91.0f;

		SphereComp.SetSimulatePhysics(false);
		SimulatePhysicsDisabled = !SphereComp.IsSimulatingPhysics();
	}
}

bool Observe_PhysicsStateReadback_DefaultFalse(ACoveragePrimitivePhysicsStateReadbackActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PrimitivePhysicsStateReadback setup: required Actor is null");
	}
	return !Actor.SimulatePhysicsEnabled
		&& !Actor.SimulatePhysicsDisabled
		&& !Actor.GravityDisabled
		&& !Actor.MassOverrideRoundTripped
		&& !Actor.LinearVelocityRoundTripped
		&& !Actor.AngularVelocityRoundTripped
		&& Actor.SphereComp == nullptr;
}

bool Observe_PhysicsStateReadback_CopyIndependence(ACoveragePrimitivePhysicsStateReadbackActor First, ACoveragePrimitivePhysicsStateReadbackActor Second)
{
	if (First is null)
	{
		throw("Test_PrimitivePhysicsStateReadback setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_PrimitivePhysicsStateReadback setup: required Second is null");
	}
	First.SimulatePhysicsEnabled = true;
	First.MassOverrideRoundTripped = true;
	return First.SimulatePhysicsEnabled
		&& First.MassOverrideRoundTripped
		&& !Second.SimulatePhysicsEnabled
		&& !Second.MassOverrideRoundTripped;
}
