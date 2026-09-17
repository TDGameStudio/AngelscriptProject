/**
 * @version v1
 * @summary UFXSystemComponent host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UFXSystemComponent
 *
 * deactivate-immediate
 */
/**
 * @begin deactivate-immediate
 * @summary SetupOwner=Runner.
 * @topic Unreal
 */
/**
 * @function ObserveDeactivateImmediateNominal
 * @summary SetupOwner=Runner.
 * @covers UFXSystemComponent.deactivate-immediate
 * @inputs UFXSystemComponent values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDeactivateImmediateNominal(UFXSystemComponent FXSystemComponent, AActor ExpectedOwner)
{
	if (FXSystemComponent is null)
	{
		throw("TS_UFXSystemComponent_Behavior_01 setup: required FXSystemComponent is null");
	}
	FXSystemComponent.DeactivateImmediate();
	FXSystemComponent.DeactivateImmediate();
	return FXSystemComponent.GetOwner() == ExpectedOwner;
}
/** @end */
