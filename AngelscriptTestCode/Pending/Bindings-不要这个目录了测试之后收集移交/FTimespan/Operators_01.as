/**
 * @version v1
 * @summary Observe non-strict ordering and tick-count equality of FTimespan.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe non-strict ordering and tick-count equality of FTimespan.
 * @topic Baseline
 */
// bool bGreaterOrEqual = Span >= Other; bool bEqual = Span == Other;
// Inputs: 1 hour vs 2 hours, identical 1 hour copies, and Zero.
// Expected observations: 1h <= 2h is true; 2h <= 1h is false. Equal copies
// compare true. Zero equals Zero and not 1h. These operators do not mutate.
// Boundary/ownership: Equality is by tick count. Compound %= is not used here.

namespace TS_FTimespan_Operators_01
{
	bool Observe_Ordering_Nominal()
	{
		FTimespan OneHour = FTimespan::FromHours(1.0);
		FTimespan TwoHours = FTimespan::FromHours(2.0);
		return (OneHour <= TwoHours) && (OneHour <= FTimespan::FromHours(1.0)) && !(TwoHours <= OneHour) && (TwoHours >= OneHour);
	}

	bool Observe_Equality_Nominal()
	{
		FTimespan Left = FTimespan::FromHours(1.0);
		FTimespan Right = FTimespan::FromMinutes(60.0);
		FTimespan Zero = FTimespan::Zero();
		return (Left == Right) && (Zero == FTimespan::Zero()) && !(Left == Zero);
	}
}
/** @end */
