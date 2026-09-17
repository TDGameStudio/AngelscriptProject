/**
 * @version v1
 * @summary Observe From* factory helpers and default/pattern ToString.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe From* factory helpers and default/pattern ToString.
 * @topic Baseline
 */
// FString FTimespan.ToString() const; FString FTimespan.ToString(const FString Format) const;
// Inputs: 1.0 for each unit, 0.0 as the zero/default, and a pattern "%h:%m:%s".
// Expected observations: FromHours(1) has 1 total hour. FromDays(0) is zero.
// Default ToString is non-empty. Pattern ToString is non-empty.
// Boundary/ownership: Factories return new durations. Format is a UE timespan
// pattern, not printf.

namespace TS_FTimespan_ConversionAndFormatting_01
{
	bool Observe_FromDays_Nominal()
	{
		FTimespan Span = FTimespan::FromDays(1.0);
		FTimespan Zero = FTimespan::FromDays(0.0);
		return Span.GetTotalDays() == 1.0 && Zero.IsZero();
	}

	bool Observe_FromHours_Nominal()
	{
		FTimespan Span = FTimespan::FromHours(2.0);
		return Span.GetTotalHours() == 2.0;
	}

	bool Observe_FromMicroseconds_Nominal()
	{
		FTimespan Span = FTimespan::FromMicroseconds(1000.0);
		return Span.GetTotalMilliseconds() == 1.0;
	}

	bool Observe_FromMilliseconds_Nominal()
	{
		FTimespan Span = FTimespan::FromMilliseconds(1000.0);
		return Span.GetTotalSeconds() == 1.0;
	}

	bool Observe_FromMinutes_Nominal()
	{
		FTimespan Span = FTimespan::FromMinutes(90.0);
		return Span.GetTotalHours() == 1.5;
	}

	bool Observe_FromSeconds_Nominal()
	{
		FTimespan Span = FTimespan::FromSeconds(60.0);
		return Span.GetTotalMinutes() == 1.0;
	}

	bool Observe_ToString_Nominal()
	{
		FTimespan Span = FTimespan::FromHours(1.0);
		FString DefaultText = Span.ToString();
		FString PatternText = Span.ToString("%h:%m:%s");
		FString ZeroText = FTimespan::Zero().ToString();
		return DefaultText.Len() > 0 && PatternText.Len() > 0 && ZeroText.Len() > 0;
	}
}
/** @end */
