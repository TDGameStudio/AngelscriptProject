// Purpose: Observe UProjectileMovementComponent.GetHomingTargetComponent on
// empty and seeded weak targets.
// Runner owns the projectile and target fixtures.
// AS-facing API: const USceneComponent UProjectileMovementComponent.GetHomingTargetComponent() const;
// Inputs: Runner-owned UProjectileMovementComponent, runner-owned
// USceneComponent as the homing target, and a nullptr clear.
// Expected observations: After SetHomingTargetComponent the getter returns
// the same identity. Clearing with nullptr returns null.
// Boundary/ownership: The homing target is a weak reference. Get does not
// keep the scene component alive. SetupOwner=Runner.

namespace TS_UProjectileMovementComponent_Queries_01
{
	bool Observe_GetHomingTargetComponent_Nominal(UProjectileMovementComponent Projectile, USceneComponent Target)
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
}
