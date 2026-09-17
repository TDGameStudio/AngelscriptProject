/**
 * @version v1
 * @summary Observe FVector.IsUnit for unit, scaled, and zero receivers.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector.IsUnit for unit, scaled, and zero receivers.
 * @topic Baseline
 */
// large LengthSquaredTolerance.
// Expected observations: Unit X is a unit vector. (2,0,0) is not. Zero is
// not. A large tolerance can treat (2,0,0) as unit when squared length is
// near one only under that wide window if the API uses |SizeSquared-1|.
// Boundary/ownership: Query does not mutate. Default tolerance is
// KINDA_SMALL_NUMBER.

namespace TS_FVector_Queries_03
{
	bool Observe_IsUnit_Nominal()
	{
		return FVector(1, 0, 0).IsUnit() &&
			!FVector(2, 0, 0).IsUnit() &&
			!FVector(0, 0, 0).IsUnit() &&
			FVector(1, 0, 0).IsUnit(1.0);
	}
}
/** @end */
