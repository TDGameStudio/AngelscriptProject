/**
 * @version v1
 * @summary Observe SetHomingTargetComponent writing the weak homing target, including repeated assignment and a nullptr clear.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe SetHomingTargetComponent writing the weak homing target, including repeated assignment and a nullptr clear.
 * @topic Baseline
 */
// Runner owns the projectile and target fixtures.
// AS-facing API: void UProjectileMovementComponent.SetHomingTargetComponent(USceneComponent HomingTargetComponent);
// Inputs: Runner-owned UProjectileMovementComponent, runner-owned
// USceneComponent target, repeated set of the same target, and nullptr.
// Expected observations: SetHomingTargetComponent is visible on
// GetHomingTargetComponent. Repeating the same target keeps that identity.
// nullptr clears the weak reference.
// Boundary/ownership: The projectile does not own the target component.
// SetupOwner=Runner.

namespace TS_UProjectileMovementComponent_MutationAndLifecycle_01
{
	bool Observe_SetHomingTargetComponent_Nominal(UProjectileMovementComponent Projectile, USceneComponent Target)
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
}
/** @end */
