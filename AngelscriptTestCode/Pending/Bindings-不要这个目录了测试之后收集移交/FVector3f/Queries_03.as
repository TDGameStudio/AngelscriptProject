/**
 * @version v1
 * @summary Observe FVector3f.IsUnit for unit, scaled, and zero receivers.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector3f.IsUnit for unit, scaled, and zero receivers.
 * @topic Baseline
 */
// not. Wide tolerance still reports the true unit vector as unit.
// Boundary/ownership: Query does not mutate. Default tolerance is
// __KINDA_SMALL_NUMBER_flt.

namespace TS_FVector3f_Queries_03
{
	bool Observe_IsUnit_Nominal()
	{
		bool bUnit = FVector3f(1.0f, 0.0f, 0.0f).IsUnit();
		bool bScaled = FVector3f(2.0f, 0.0f, 0.0f).IsUnit();
		bool bZero = FVector3f(0.0f, 0.0f, 0.0f).IsUnit();
		bool bWide = FVector3f(1.0f, 0.0f, 0.0f).IsUnit(1.0f);
		return bUnit && !bScaled && !bZero && bWide;
	}
}
/** @end */
