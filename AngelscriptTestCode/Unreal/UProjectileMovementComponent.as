/**
 * @version v1
 * @summary UProjectileMovementComponent host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UProjectileMovementComponent
 *
 * set-homing-target-component
 * get-homing-target-component
 */
/**
 * @begin set-homing-target-component
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveSetHomingTargetComponentNominal
 * @summary SetupOwner=Runner.
 * @covers UProjectileMovementComponent.set-homing-target-component
 * @inputs UProjectileMovementComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSetHomingTargetComponentNominal(UProjectileMovementComponent Projectile, USceneComponent Target)
{
	if (Projectile is null)
	{
		throw("TS_UProjectileMovementComponent_MutationAndLifecycle_01 setup: required Projectile is null");
	}
	if (Target is null)
	{
		throw("TS_UProjectileMovementComponent_MutationAndLifecycle_01 setup: required Target is null");
	}
	USceneComponent Original = Projectile.GetHomingTargetComponent();
	Projectile.SetHomingTargetComponent(Target);
	USceneComponent First = Projectile.GetHomingTargetComponent();
	Projectile.SetHomingTargetComponent(Target);
	USceneComponent Repeated = Projectile.GetHomingTargetComponent();
	Projectile.SetHomingTargetComponent(nullptr);
	USceneComponent Cleared = Projectile.GetHomingTargetComponent();
	Projectile.SetHomingTargetComponent(Original);
	return First == Target && Repeated == Target && Cleared is null;
}
/** @end */
/**
 * @begin get-homing-target-component
 * @summary keep the scene component alive.
 * @topic Unreal
 */
/**
 * @function ObserveGetHomingTargetComponentNominal
 * @summary keep the scene component alive.
 * @covers UProjectileMovementComponent.get-homing-target-component
 * @inputs UProjectileMovementComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetHomingTargetComponentNominal(UProjectileMovementComponent Projectile, USceneComponent Target)
{
	if (Projectile is null)
	{
		throw("TS_UProjectileMovementComponent_Queries_01 setup: required Projectile is null");
	}
	if (Target is null)
	{
		throw("TS_UProjectileMovementComponent_Queries_01 setup: required Target is null");
	}
	USceneComponent Original = Projectile.GetHomingTargetComponent();
	Projectile.SetHomingTargetComponent(Target);
	USceneComponent Stored = Projectile.GetHomingTargetComponent();
	Projectile.SetHomingTargetComponent(nullptr);
	USceneComponent Cleared = Projectile.GetHomingTargetComponent();
	Projectile.SetHomingTargetComponent(Original);
	return Stored == Target && Cleared is null;
}
/** @end */
