/**
 * @version v1
 * @summary Simulation, gravity, mass and both velocity components read back off a sphere component. C++ verifies the six flags by path. The observers cover the local-construct default and copy independence.
 * @topic World
 */
/**
 * @version root
 * @summary Simulation, gravity, mass and both velocity components read back off a sphere component. C++ verifies the six flags by path. The observers cover the local-construct default and copy independence.
 * @topic Baseline
 */
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

	/**
	 * WorldStory: BeginPlay walks simulation, gravity, the mass override and both
	 * velocities, reading each back within a tolerance, then switches simulation off.
	 *
	 * @Kind WorldStory
	 * @Covers Component.PrimitivePhysicsStateReadback
	 * @Inputs a default-attached USphereComponent
	 * @Return all six flags true; mass 125, linear (120, 30, 0), angular (0, 45, 90)
	 */
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

	/**
	 * Observe that a locally constructed actor has no flags and no component.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitivePhysicsStateReadback
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when all six flags are clear and SphereComp is null
	 * @Boundary null default component
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (SimulatePhysicsEnabled)
		{
			return false;
		}
		if (SimulatePhysicsDisabled)
		{
			return false;
		}
		if (GravityDisabled)
		{
			return false;
		}
		if (MassOverrideRoundTripped)
		{
			return false;
		}
		if (LinearVelocityRoundTripped)
		{
			return false;
		}
		if (AngularVelocityRoundTripped)
		{
			return false;
		}
		return SphereComp == nullptr;
	}

	/**
	 * Observe that writing this actor leaves another actor untouched.
	 *
	 * @Kind Observe
	 * @Covers Component.PrimitivePhysicsStateReadback
	 * @Inputs this actor plus a second actor
	 * @Return true when this holds both flags and the other stays clear
	 * @Param Second the other actor, expected to stay at its defaults
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoveragePrimitivePhysicsStateReadbackActor Second)
	{
		if (Second is null)
		{
			throw("PrimitivePhysicsStateReadback setup: required Second is null");
		}
		SimulatePhysicsEnabled = true;
		MassOverrideRoundTripped = true;

		if (!SimulatePhysicsEnabled)
		{
			return false;
		}
		if (!MassOverrideRoundTripped)
		{
			return false;
		}
		if (Second.SimulatePhysicsEnabled)
		{
			return false;
		}
		return !Second.MassOverrideRoundTripped;
	}
}
/** @end */
