/**
 * @version v1
 * @summary Observe FTimespan component accessors, absolute duration, and tick count for positive, negative, and zero values.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTimespan component accessors, absolute duration, and tick count for positive, negative, and zero values.
 * @topic Baseline
 */
// GetHours, GetMinutes, GetSeconds, GetTicks.
// Inputs: 1 day + 2 hours + 3 minutes + 4 seconds + 5 ms constructed via
// FromSeconds and component constructors, a negated span, and Zero.
// Expected observations: Days/hours/minutes/seconds match the seeded
// components. GetDuration of a negative span is positive. Zero ticks is 0.
// Boundary/ownership: GetDuration returns a new absolute span. Component
// getters do not mutate the receiver.

namespace TS_FTimespan_Queries_01
{
	bool Observe_GetDays_Nominal()
	{
		FTimespan Span = FTimespan::FromDays(2.0);
		FTimespan Zero = FTimespan::Zero();
		return Span.GetDays() == 2 && Zero.GetDays() == 0;
	}

	bool Observe_GetDuration_Nominal()
	{
		FTimespan Negative = -FTimespan::FromHours(1.0);
		FTimespan Absolute = Negative.GetDuration();
		return Absolute.GetTotalHours() == 1.0 && Negative.GetTotalHours() == -1.0;
	}

	bool Observe_GetFractionMicro_Nominal()
	{
		FTimespan Span = FTimespan::FromMicroseconds(250.0);
		return Span.GetFractionMicro() == 250;
	}

	bool Observe_GetFractionMilli_Nominal()
	{
		FTimespan Span = FTimespan::FromMilliseconds(5.0);
		return Span.GetFractionMilli() == 5;
	}

	bool Observe_GetFractionNano_Nominal()
	{
		FTimespan Span = FTimespan(0, 0, 0, 0, 100);
		return Span.GetFractionNano() == 100;
	}

	bool Observe_GetFractionTicks_Nominal()
	{
		FTimespan Span = FTimespan::FromMilliseconds(1.0);
		return Span.GetFractionTicks() == 10000;
	}

	bool Observe_GetHours_Nominal()
	{
		FTimespan Span = FTimespan(2, 3, 0);
		return Span.GetHours() == 2;
	}

	bool Observe_GetMinutes_Nominal()
	{
		FTimespan Span = FTimespan(2, 3, 4);
		return Span.GetMinutes() == 3;
	}

	bool Observe_GetSeconds_Nominal()
	{
		FTimespan Span = FTimespan(2, 3, 4);
		return Span.GetSeconds() == 4;
	}

	bool Observe_GetTicks_Nominal()
	{
		FTimespan Span = FTimespan::FromSeconds(1.0);
		FTimespan Zero = FTimespan::Zero();
		return Span.GetTicks() > 0 && Zero.GetTicks() == 0;
	}
}
/** @end */
