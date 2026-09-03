/**
 * Linear and angular velocity set flags on a simulating sphere. C++ verifies
 * LinearVelocitySet and AngularVelocitySet by path after BeginPlay, so those
 * UPROPERTY names are part of the contract and are kept verbatim. The observer
 * covers the local-construct defaults.
 *
 * @Theme Gameplay.Physics
 * @Subject Physics.PhysicsVelocity
 * @Harness UClass
 * @Tag Gameplay.Physics.PhysicsVelocity
 * @Provenance Theme: Gameplay.Physics. WorldStory linear/angular velocity set flags.
 * @Provenance C++: AngelscriptCoveragePhysicsTests.cpp::PhysicsVelocity
 * @Provenance Oracle VerifyByPath after BeginPlay: LinearVelocitySet true, AngularVelocitySet true.
 * @Provenance Extra: default FVector empty / flags false. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoveragePhysicsVelocityActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY()
	bool LinearVelocitySet = false;

	UPROPERTY()
	bool AngularVelocitySet = false;

	UPROPERTY()
	FVector LinearVelocity;

	UPROPERTY()
	FVector AngularVelocity;

	/**
	 * WorldStory: BeginPlay enables simulation, then writes linear and angular
	 * velocity and reads each back.
	 *
	 * @Kind WorldStory
	 * @Covers Physics.PhysicsVelocity
	 * @Inputs a default-attached USphereComponent
	 * @Return LinearVelocitySet and AngularVelocitySet true
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Sphere.SetSimulatePhysics(true);

		// Set linear velocity
		FVector TargetLinearVel = FVector(100, 0, 0);
		Sphere.SetPhysicsLinearVelocity(TargetLinearVel, false, NAME_None);
		LinearVelocity = Sphere.GetPhysicsLinearVelocity(NAME_None);
		LinearVelocitySet = (LinearVelocity.Size() > 50.0f);

		// Set angular velocity
		FVector TargetAngularVel = FVector(0, 0, 45);
		Sphere.SetPhysicsAngularVelocityInDegrees(TargetAngularVel, false, NAME_None);
		AngularVelocity = Sphere.GetPhysicsAngularVelocityInDegrees(NAME_None);
		AngularVelocitySet = (AngularVelocity.Size() > 20.0f);
	}

	/**
	 * Observe that a locally constructed actor holds both flags false and both
	 * velocities at zero.
	 *
	 * @Kind Observe
	 * @Covers Physics.PhysicsVelocity
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when LinearVelocitySet and AngularVelocitySet are false and both
	 * velocity vectors equal the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (LinearVelocitySet)
		{
			return false;
		}
		if (AngularVelocitySet)
		{
			return false;
		}
		if (!LinearVelocity.Equals(FVector::ZeroVector))
		{
			return false;
		}
		return AngularVelocity.Equals(FVector::ZeroVector);
	}
}
