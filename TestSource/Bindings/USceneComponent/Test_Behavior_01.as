// Purpose: Observe FScopedMovementUpdate deferring movement until the scope
// leaves its script lifetime.
// Runner owns the Component fixture.
// AS-facing API: FScopedMovementUpdate Scope(USceneComponent Component);
// Inputs: Runner-owned USceneComponent and a relative location written while
// the scope is alive.
// Expected observations: SetRelativeLocation issued inside the scope still
// executes. After the scope leaves, GetLocation X is 10.
// Boundary/ownership: The scope borrows the component. Nested construction is
// not required. Destroying the value is the lifecycle boundary.
// SetupOwner=Runner.

namespace TS_USceneComponent_Behavior_01
{
	bool Observe_Scope_Nominal(USceneComponent Component)
	{
		if (Component is null)
		{
			throw("TS_USceneComponent_Behavior_01 setup: required Component is null");
		}
		FVector Target(10.0, 0.0, 0.0);
		{
			FScopedMovementUpdate Scope(Component);
			Component.SetRelativeLocation(Target);
		}
		FVector After = Component.GetComponentTransform().GetLocation();
		Component.SetRelativeLocation(FVector::ZeroVector);
		return After.X == 10.0;
	}
}
