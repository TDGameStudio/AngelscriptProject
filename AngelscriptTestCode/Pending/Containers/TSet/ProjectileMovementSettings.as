/**
 * @version v1
 * @summary Not TSet API. Kept here until moved.
 * @topic Containers
 */
/**
 * @version root
 * @summary Not TSet API. Kept here until moved.
 * @topic Baseline
 */
// CompileScriptModule + spawn + BeginPlay. Oracle: ProjectileScalarSettingsSet,
// ProjectileHomingTargetSet, ProjectileRuntimeStateStable all true.
// Extra: local construct leaves flags false.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoveragePhysicsProjectileMovementActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USphereComponent Sphere;

	UPROPERTY(DefaultComponent)
	UProjectileMovementComponent Projectile;

	UPROPERTY()
	bool ProjectileScalarSettingsSet = false;

	UPROPERTY()
	bool ProjectileHomingTargetSet = false;

	UPROPERTY()
	bool ProjectileRuntimeStateStable = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Projectile.InitialSpeed = 1200.0f;
		Projectile.MaxSpeed = 2400.0f;
		Projectile.Bounciness = 0.65f;
		Projectile.ProjectileGravityScale = 0.25f;

		Projectile.SetHomingTargetComponent(Sphere);

		ProjectileScalarSettingsSet =
			Projectile.InitialSpeed > 1199.0f
			&& Projectile.MaxSpeed > 2399.0f
			&& Projectile.Bounciness > 0.64f
			&& Projectile.ProjectileGravityScale > 0.24f;

		ProjectileHomingTargetSet = (Projectile.GetHomingTargetComponent() == Sphere);

		Projectile.SetHomingTargetComponent(nullptr);
		ProjectileRuntimeStateStable = Projectile.GetHomingTargetComponent() == nullptr;
	}
}

bool Observe_ProjectileMovement_DefaultEmpty(ACoveragePhysicsProjectileMovementActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ProjectileMovementSettings setup: required Actor is null");
	}
	return Actor.ProjectileScalarSettingsSet == false
		&& Actor.ProjectileHomingTargetSet == false
		&& Actor.ProjectileRuntimeStateStable == false;
}

bool Observe_ProjectileMovement_CopyIndependence(ACoveragePhysicsProjectileMovementActor First, ACoveragePhysicsProjectileMovementActor Second)
{
	if (First is null)
	{
		throw("Test_ProjectileMovementSettings setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ProjectileMovementSettings setup: required Second is null");
	}
	First.ProjectileScalarSettingsSet = true;
	return First.ProjectileScalarSettingsSet == true && Second.ProjectileScalarSettingsSet == false;
}
/** @end */
