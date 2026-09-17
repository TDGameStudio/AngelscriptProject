/**
 * @version v1
 * @summary Observe UFXSystemComponent.DeactivateImmediate stopping an FX system without waiting for normal completion.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UFXSystemComponent.DeactivateImmediate stopping an FX system without waiting for normal completion.
 * @topic Baseline
 */
// Runner owns the FX component fixture. Null component is setup failure.
// AS-facing API: void FXSystemComponent.DeactivateImmediate();
// Inputs: Runner-owned FX-system component, ExpectedOwner, and a repeated
// DeactivateImmediate call.
// Expected observations: The void call is issued twice. GetOwner matches the
// runner-supplied expected owner after both stops.
// Boundary/ownership: Immediate deactivation does not wait for particles or
// Niagara to finish. The component remains the runner-owned handle.
// SetupOwner=Runner. CleanupOwner=Runner.

namespace TS_UFXSystemComponent_Behavior_01
{
	bool Observe_DeactivateImmediate_Nominal(UFXSystemComponent FXSystemComponent, AActor ExpectedOwner)
	{
		if (FXSystemComponent is null)
		{
			throw("TS_UFXSystemComponent_Behavior_01 setup: required FXSystemComponent is null");
		}
		FXSystemComponent.DeactivateImmediate();
		FXSystemComponent.DeactivateImmediate();
		return FXSystemComponent.GetOwner() == ExpectedOwner;
	}
}
/** @end */
