/**
 * @version v1
 * @summary Observe FScopedMovementUpdate as the RAII movement-update scope type bound for scene components.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FScopedMovementUpdate as the RAII movement-update scope type bound for scene components.
 * @topic Baseline
 */
// Runner owns the Component fixture.
// AS-facing API: struct FScopedMovementUpdate;
// Inputs: Runner-owned USceneComponent as the explicit constructor argument.
// Expected observations: Constructing FScopedMovementUpdate with a live
// component handle succeeds and the component remains valid.
// Boundary/ownership: The scope borrows the component. Destructor applies
// deferred movement when the script value is destroyed. No default constructor
// is published. SetupOwner=Runner.

namespace TS_USceneComponent_ConstructionAndAssignment_01
{
	// FScopedMovementUpdate borrows the component; construction succeeds on a live handle.
	bool Observe_Surface010_Nominal(USceneComponent Component)
	{
		if (Component is null)
		{
			throw("TS_USceneComponent_ConstructionAndAssignment_01 setup: required Component is null");
		}
		FScopedMovementUpdate Scope(Component);
		return IsValid(Component) && Component.GetNumChildrenComponents() >= 0;
	}
}
/** @end */
