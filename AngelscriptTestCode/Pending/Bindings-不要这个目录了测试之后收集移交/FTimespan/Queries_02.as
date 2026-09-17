/**
 * @version v1
 * @summary Observe total-unit getters, IsZero, and min/max sentinels.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe total-unit getters, IsZero, and min/max sentinels.
 * @topic Baseline
 */
// bool FTimespan.IsZero() const; FTimespan::MaxValue(); FTimespan::MinValue();
// Inputs: One hour, Zero, a negative one hour, MaxValue and MinValue.
// Expected observations: One hour is 1 total hour and 60 total minutes.
// Zero.IsZero is true; one hour is not. MaxValue > Zero > MinValue.
// Boundary/ownership: MinValue is the most negative representable duration,
// not an empty optional.

namespace TS_FTimespan_Queries_02
{
	bool Observe_GetTotalDays_Nominal()
	{
		FTimespan Span = FTimespan::FromHours(24.0);
		return Span.GetTotalDays() == 1.0;
	}

	bool Observe_GetTotalHours_Nominal()
	{
		FTimespan Span = FTimespan::FromMinutes(90.0);
		return Span.GetTotalHours() == 1.5;
	}

	bool Observe_GetTotalMicroseconds_Nominal()
	{
		FTimespan Span = FTimespan::FromMilliseconds(1.0);
		return Span.GetTotalMicroseconds() == 1000.0;
	}

	bool Observe_GetTotalMilliseconds_Nominal()
	{
		FTimespan Span = FTimespan::FromSeconds(1.0);
		return Span.GetTotalMilliseconds() == 1000.0;
	}

	bool Observe_GetTotalMinutes_Nominal()
	{
		FTimespan Span = FTimespan::FromHours(1.0);
		return Span.GetTotalMinutes() == 60.0;
	}

	bool Observe_GetTotalSeconds_Nominal()
	{
		FTimespan Span = FTimespan::FromMinutes(1.0);
		return Span.GetTotalSeconds() == 60.0;
	}

	bool Observe_IsZero_Nominal()
	{
		return FTimespan::Zero().IsZero() && !FTimespan::FromHours(1.0).IsZero();
	}

	bool Observe_MaxValue_Nominal()
	{
		FTimespan MaxValue = FTimespan::MaxValue();
		return MaxValue > FTimespan::Zero();
	}

	bool Observe_MinValue_Nominal()
	{
		FTimespan MinValue = FTimespan::MinValue();
		return MinValue < FTimespan::Zero();
	}
}
/** @end */
