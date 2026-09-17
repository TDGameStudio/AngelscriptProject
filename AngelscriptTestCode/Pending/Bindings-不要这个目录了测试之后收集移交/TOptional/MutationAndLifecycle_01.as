/**
 * @version v1
 * @summary Observe TOptional Set and Reset, including repeated Set and Reset on an already unset optional. Each function returns the exact comparison.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe TOptional Set and Reset, including repeated Set and Reset on an already unset optional. Each function returns the exact comparison.
 * @topic Baseline
 */
// Optional.Reset();
// Inputs: Unset optional, Set(7) then Set(11), Reset, and a second Reset.
// Expected observations: Set(7) marks IsSet and GetValue 7. Set(11) replaces
// the value. Reset clears IsSet. A second Reset remains unset.
// Boundary/ownership: Set copies the value into optional storage. Reset
// destroys the contained value. Set is a const method on the wrapper.

namespace TS_TOptional_MutationAndLifecycle_01
{
	bool Observe_Set_Nominal()
	{
		TOptional<int32> Optional;
		Optional.Set(7);
		bool bFirstSet = Optional.IsSet() && Optional.GetValue() == 7;
		Optional.Set(11);
		TOptional<FName> Named;
		Named.Set(n"Alpha");
		return bFirstSet && Optional.GetValue() == 11 && Named.IsSet() && Named.GetValue() == n"Alpha";
	}

	bool Observe_Reset_Nominal()
	{
		TOptional<int32> Optional;
		Optional.Set(7);
		Optional.Reset();
		bool bResetUnset = !Optional.IsSet();
		Optional.Reset();
		return bResetUnset && !Optional.IsSet();
	}
}
/** @end */
