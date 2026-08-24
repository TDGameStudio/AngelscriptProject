// Theme: Gameplay.Physics. WorldStory linear/angular velocity set flags.
// C++: AngelscriptCoveragePhysicsTests.cpp::PhysicsVelocity
// Oracle VerifyByPath after BeginPlay: LinearVelocitySet true, AngularVelocitySet true.
// Extra: default FVector empty / flags false. FixtureIsolated. Keep UPROPERTY names.

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
}

bool Observe_PhysicsVelocity_Defaults(ACoveragePhysicsVelocityActor Actor)
{
	if (Actor is null)
	{
		throw("Test_PhysicsVelocity setup: required Actor is null");
	}
	return Actor.LinearVelocitySet == false
		&& Actor.AngularVelocitySet == false
		&& Actor.LinearVelocity.Equals(FVector::ZeroVector)
		&& Actor.AngularVelocity.Equals(FVector::ZeroVector);
}
