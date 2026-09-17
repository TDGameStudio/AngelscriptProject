/**
 * @version v1
 * @summary Observe FVector2f zero and unit-component constants.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2f zero and unit-component constants.
 * @topic Baseline
 */
// const FVector2f FVector2f::UnitVector.
// Inputs: Each published constant compared against (0,0) and (1,1).
// Expected observations: ZeroVector is (0,0). UnitVector is (1,1).
// Boundary/ownership: Constants are shared values, not factory functions.

namespace TS_FVector2f_NamespaceAndGlobalFunctions_01
{
	// FVector2f::ZeroVector is (0,0). Shared constant, not a factory.
	bool Observe_Surface048_Nominal()
	{
		return FVector2f::ZeroVector.X == 0.0f && FVector2f::ZeroVector.Y == 0.0f;
	}

	// FVector2f::UnitVector is (1,1). Shared constant, not a factory.
	bool Observe_Surface049_Nominal()
	{
		return FVector2f::UnitVector.X == 1.0f && FVector2f::UnitVector.Y == 1.0f;
	}
}
/** @end */
