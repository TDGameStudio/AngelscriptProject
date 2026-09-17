/**
 * @version v1
 * @summary Observe FTimespan constructors from ticks and calendar components plus strict less/greater ordering.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTimespan constructors from ticks and calendar components plus strict less/greater ordering.
 * @topic Baseline
 */
// FTimespan Value(int32 Hours, int32 Minutes, int32 Seconds);
// FTimespan Value(int32 Days, int32 Hours, int32 Minutes, int32 Seconds);
// FTimespan Value(int32 Days, int32 Hours, int32 Minutes, int32 Seconds, int32 FractionNano);
// bool bLess = Span < Other; bool bGreater = Span > Other;
// Inputs: Ticks 0, (1,2,3), (1,1,2,3), nanosecond 100, and 1h vs 2h.
// Expected observations: Tick 0 is zero. HMS constructor stores 1 hour.
// Day constructor stores 1 day. 1h < 2h is true; 2h > 1h is true.
// Boundary/ownership: Construction produces a value type. FractionNano is
// sub-second nanoseconds added to the duration.

namespace TS_FTimespan_Behavior_01
{
	bool Observe_Value_Nominal()
	{
		FTimespan FromTicks(0);
		FTimespan FromHms(1, 2, 3);
		FTimespan FromDays(1, 1, 2, 3);
		FTimespan FromNano(0, 0, 0, 0, 100);
		return FromTicks.IsZero() && FromHms.GetHours() == 1 && FromHms.GetMinutes() == 2 && FromHms.GetSeconds() == 3 && FromDays.GetDays() == 1 && FromDays.GetHours() == 1 && FromNano.GetFractionNano() == 100;
	}

	bool Observe_Ordering_Nominal()
	{
		FTimespan OneHour = FTimespan::FromHours(1.0);
		FTimespan TwoHours = FTimespan::FromHours(2.0);
		return (OneHour < TwoHours) && !(TwoHours < OneHour) && (TwoHours > OneHour) && !(OneHour > TwoHours);
	}
}
/** @end */
