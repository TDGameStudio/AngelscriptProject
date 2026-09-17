/**
 * @version v1
 * @summary FTimespan host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FTimespan
 *
 * container-api
 * ordering
 * assignment
 * add-assign
 * subtract-assign
 * multiply-assign
 * divide-assign
 * mutates-span-only
 * from-days
 * from-hours
 * from-microseconds
 * from-milliseconds
 * from-minutes
 * from-seconds
 * to-string
 * zero
 * ratio
 * FTimespan-Operators_01-ordering
 * equality
 * get-days
 * get-duration
 * get-fraction-micro
 * get-fraction-milli
 * get-fraction-nano
 * get-fraction-ticks
 * get-hours
 * get-minutes
 * get-seconds
 * get-ticks
 * get-total-days
 * get-total-hours
 * get-total-microseconds
 * get-total-milliseconds
 * get-total-minutes
 * get-total-seconds
 * is-zero
 * max-value
 * min-value
 */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary Observe the container API.
 * @covers FTimespan.container-api
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FTimespan Value(int32 Hours, int32 Minutes, int32 Seconds);
// FTimespan Value(int32 Days, int32 Hours, int32 Minutes, int32 Seconds);
// FTimespan Value(int32 Days, int32 Hours, int32 Minutes, int32 Seconds, int32 FractionNano);
// bool bLess = Span < Other; bool bGreater = Span > Other;
// Inputs: Ticks 0, (1,2,3), (1,1,2,3), nanosecond 100, and 1h vs 2h.
// Expected observations: Tick 0 is zero. HMS constructor stores 1 hour.
// Day constructor stores 1 day. 1h < 2h is true; 2h > 1h is true.
// Boundary/ownership: Construction produces a value type. FractionNano is
// sub-second nanoseconds added to the duration.
bool ObserveValueNominal()
{
	FTimespan FromTicks(0);
	FTimespan FromHms(1, 2, 3);
	FTimespan FromDays(1, 1, 2, 3);
	FTimespan FromNano(0, 0, 0, 0, 100);
	return FromTicks.IsZero() && FromHms.GetHours() == 1 && FromHms.GetMinutes() == 2 && FromHms.GetSeconds() == 3 && FromDays.GetDays() == 1 && FromDays.GetHours() == 1 && FromNano.GetFractionNano() == 100;
}
/** @end */
/**
 * @begin ordering
 * @summary sub-second nanoseconds added to the duration.
 * @topic Unreal
 */
/**
 * @function ObserveOrderingNominal
 * @summary sub-second nanoseconds added to the duration.
 * @covers FTimespan.ordering
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveOrderingNominal()
{
	FTimespan OneHour = FTimespan::FromHours(1.0);
	FTimespan TwoHours = FTimespan::FromHours(2.0);
	return (OneHour < TwoHours) && !(TwoHours < OneHour) && (TwoHours > OneHour) && !(OneHour > TwoHours);
}
/** @end */
/**
 * @begin assignment
 * @summary Compound assignment mutates Span only.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Compound assignment mutates Span only.
 * @covers FTimespan.assignment
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FTimespan Span = FTimespan::FromHours(1.0);
	FTimespan Other = FTimespan::FromMinutes(30.0);
	FTimespan Sum = Span + Other;
	FTimespan Original = Span;
	FTimespan Negated = -Span;
	return Sum.GetTotalMinutes() == 90.0 && Negated.GetTotalHours() == -1.0 && Original.GetTotalHours() == 1.0;
}
/** @end */
/**
 * @begin add-assign
 * @summary Compound assignment mutates Span only.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary Compound assignment mutates Span only.
 * @covers FTimespan.add-assign
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FTimespan Span = FTimespan::FromHours(1.0);
	FTimespan Other = FTimespan::FromMinutes(30.0);
	Span += Other;
	return Span.GetTotalMinutes() == 90.0 && Other.GetTotalMinutes() == 30.0;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary Compound assignment mutates Span only.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary Compound assignment mutates Span only.
 * @covers FTimespan.subtract-assign
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSubtractAssignNominal()
{
	FTimespan Span = FTimespan::FromHours(1.0);
	FTimespan Other = FTimespan::FromMinutes(30.0);
	FTimespan Difference = Span - Other;
	Span -= Other;
	return Difference.GetTotalMinutes() == 30.0 && Span.GetTotalMinutes() == 30.0;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary Compound assignment mutates Span only.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary Compound assignment mutates Span only.
 * @covers FTimespan.multiply-assign
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMultiplyAssignNominal()
{
	FTimespan Span = FTimespan::FromHours(1.0);
	FTimespan Scaled = Span * 2.0;
	Span *= 2.0;
	return Scaled.GetTotalHours() == 2.0 && Span.GetTotalHours() == 2.0;
}
/** @end */
/**
 * @begin divide-assign
 * @summary Compound assignment mutates Span only.
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary Compound assignment mutates Span only.
 * @covers FTimespan.divide-assign
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDivideAssignNominal()
{
	FTimespan Span = FTimespan::FromHours(2.0);
	FTimespan Divided = Span / 2.0;
	Span /= 2.0;
	FTimespan Ninety = FTimespan::FromMinutes(90.0);
	FTimespan Remainder = Ninety % FTimespan::FromHours(1.0);
	return Divided.GetTotalHours() == 1.0 && Span.GetTotalHours() == 1.0 && Remainder.GetTotalMinutes() == 30.0;
}
/** @end */
/**
 * @begin mutates-span-only
 * @summary Mutates Span only.
 * @topic Unreal
 */
/**
 * @function ObserveSurface015Nominal
 * @summary Mutates Span only.
 * @covers FTimespan.mutates-span-only
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface015Nominal()
{
	FTimespan Span = FTimespan::FromMinutes(90.0);
	FTimespan Other = FTimespan::FromHours(1.0);
	FTimespan OriginalOther = Other;
	Span %= Other;
	bool bRemainderIsThirty = Span.GetTotalMinutes() == 30.0;
	Span %= FTimespan::FromMinutes(30.0);
	return bRemainderIsThirty && Other == OriginalOther && Span.IsZero();
}
/** @end */
/**
 * @begin from-days
 * @summary Expected
 * @topic Unreal
 */
/**
 * @function ObserveFromDaysNominal
 * @summary Expected
 * @covers FTimespan.from-days
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

 observations: FromHours(1) has 1 total hour. FromDays(0) is zero.
// Default ToString is non-empty. Pattern ToString is non-empty.
// Boundary/ownership: Factories return new durations. Format is a UE timespan
// pattern, not printf.
bool ObserveFromDaysNominal()
{
	FTimespan Span = FTimespan::FromDays(1.0);
	FTimespan Zero = FTimespan::FromDays(0.0);
	return Span.GetTotalDays() == 1.0 && Zero.IsZero();
}
/** @end */
/**
 * @begin from-hours
 * @summary pattern, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveFromHoursNominal
 * @summary pattern, not printf.
 * @covers FTimespan.from-hours
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveFromHoursNominal()
{
	FTimespan Span = FTimespan::FromHours(2.0);
	return Span.GetTotalHours() == 2.0;
}
/** @end */
/**
 * @begin from-microseconds
 * @summary pattern, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveFromMicrosecondsNominal
 * @summary pattern, not printf.
 * @covers FTimespan.from-microseconds
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveFromMicrosecondsNominal()
{
	FTimespan Span = FTimespan::FromMicroseconds(1000.0);
	return Span.GetTotalMilliseconds() == 1.0;
}
/** @end */
/**
 * @begin from-milliseconds
 * @summary pattern, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveFromMillisecondsNominal
 * @summary pattern, not printf.
 * @covers FTimespan.from-milliseconds
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveFromMillisecondsNominal()
{
	FTimespan Span = FTimespan::FromMilliseconds(1000.0);
	return Span.GetTotalSeconds() == 1.0;
}
/** @end */
/**
 * @begin from-minutes
 * @summary pattern, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveFromMinutesNominal
 * @summary pattern, not printf.
 * @covers FTimespan.from-minutes
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveFromMinutesNominal()
{
	FTimespan Span = FTimespan::FromMinutes(90.0);
	return Span.GetTotalHours() == 1.5;
}
/** @end */
/**
 * @begin from-seconds
 * @summary pattern, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveFromSecondsNominal
 * @summary pattern, not printf.
 * @covers FTimespan.from-seconds
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveFromSecondsNominal()
{
	FTimespan Span = FTimespan::FromSeconds(60.0);
	return Span.GetTotalMinutes() == 1.0;
}
/** @end */
/**
 * @begin to-string
 * @summary pattern, not printf.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary pattern, not printf.
 * @covers FTimespan.to-string
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected

bool ObserveToStringNominal()
{
	FTimespan Span = FTimespan::FromHours(1.0);
	FString DefaultText = Span.ToString();
	FString PatternText = Span.ToString("%h:%m:%s");
	FString ZeroText = FTimespan::Zero().ToString();
	return DefaultText.Len() > 0 && PatternText.Len() > 0 && ZeroText.Len() > 0;
}
/** @end */
/**
 * @begin zero
 * @summary a diagnostic boundary and is not invoked in the nominal path.
 * @topic Unreal
 */
/**
 * @function ObserveZeroNominal
 * @summary a diagnostic boundary and is not invoked in the nominal path.
 * @covers FTimespan.zero
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveZeroNominal()
{
	FTimespan Zero = FTimespan::Zero();
	return Zero.IsZero() && Zero.GetTicks() == 0;
}
/** @end */
/**
 * @begin ratio
 * @summary a diagnostic boundary and is not invoked in the nominal path.
 * @topic Unreal
 */
/**
 * @function ObserveRatioNominal
 * @summary a diagnostic boundary and is not invoked in the nominal path.
 * @covers FTimespan.ratio
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRatioNominal()
{
	float64 Two = FTimespan::Ratio(FTimespan::FromHours(2.0), FTimespan::FromHours(1.0));
	float64 One = FTimespan::Ratio(FTimespan::FromMinutes(30.0), FTimespan::FromMinutes(30.0));
	return Two == 2.0 && One == 1.0;
}
/** @end */
/**
 * @begin FTimespan-Operators_01-ordering
 * @summary Boundary/ownership: Equality is by tick count.
 * @topic Unreal
 */
/**
 * @function ObserveOrderingNominal
 * @summary Boundary/ownership: Equality is by tick count.
 * @covers FTimespan.ordering
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOrderingNominal()
{
	FTimespan OneHour = FTimespan::FromHours(1.0);
	FTimespan TwoHours = FTimespan::FromHours(2.0);
	return (OneHour <= TwoHours) && (OneHour <= FTimespan::FromHours(1.0)) && !(TwoHours <= OneHour) && (TwoHours >= OneHour);
}
/** @end */
/**
 * @begin equality
 * @summary Boundary/ownership: Equality is by tick count.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Boundary/ownership: Equality is by tick count.
 * @covers FTimespan.equality
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FTimespan Left = FTimespan::FromHours(1.0);
	FTimespan Right = FTimespan::FromMinutes(60.0);
	FTimespan Zero = FTimespan::Zero();
	return (Left == Right) && (Zero == FTimespan::Zero()) && !(Left == Zero);
}
/** @end */
/**
 * @begin get-days
 * @summary getters do not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetDaysNominal
 * @summary getters do not mutate the receiver.
 * @covers FTimespan.get-days
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDaysNominal()
{
	FTimespan Span = FTimespan::FromDays(2.0);
	FTimespan Zero = FTimespan::Zero();
	return Span.GetDays() == 2 && Zero.GetDays() == 0;
}
/** @end */
/**
 * @begin get-duration
 * @summary getters do not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetDurationNominal
 * @summary getters do not mutate the receiver.
 * @covers FTimespan.get-duration
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDurationNominal()
{
	FTimespan Negative = -FTimespan::FromHours(1.0);
	FTimespan Absolute = Negative.GetDuration();
	return Absolute.GetTotalHours() == 1.0 && Negative.GetTotalHours() == -1.0;
}
/** @end */
/**
 * @begin get-fraction-micro
 * @summary getters do not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetFractionMicroNominal
 * @summary getters do not mutate the receiver.
 * @covers FTimespan.get-fraction-micro
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetFractionMicroNominal()
{
	FTimespan Span = FTimespan::FromMicroseconds(250.0);
	return Span.GetFractionMicro() == 250;
}
/** @end */
/**
 * @begin get-fraction-milli
 * @summary getters do not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetFractionMilliNominal
 * @summary getters do not mutate the receiver.
 * @covers FTimespan.get-fraction-milli
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetFractionMilliNominal()
{
	FTimespan Span = FTimespan::FromMilliseconds(5.0);
	return Span.GetFractionMilli() == 5;
}
/** @end */
/**
 * @begin get-fraction-nano
 * @summary getters do not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetFractionNanoNominal
 * @summary getters do not mutate the receiver.
 * @covers FTimespan.get-fraction-nano
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetFractionNanoNominal()
{
	FTimespan Span = FTimespan(0, 0, 0, 0, 100);
	return Span.GetFractionNano() == 100;
}
/** @end */
/**
 * @begin get-fraction-ticks
 * @summary getters do not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetFractionTicksNominal
 * @summary getters do not mutate the receiver.
 * @covers FTimespan.get-fraction-ticks
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetFractionTicksNominal()
{
	FTimespan Span = FTimespan::FromMilliseconds(1.0);
	return Span.GetFractionTicks() == 10000;
}
/** @end */
/**
 * @begin get-hours
 * @summary getters do not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetHoursNominal
 * @summary getters do not mutate the receiver.
 * @covers FTimespan.get-hours
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetHoursNominal()
{
	FTimespan Span = FTimespan(2, 3, 0);
	return Span.GetHours() == 2;
}
/** @end */
/**
 * @begin get-minutes
 * @summary getters do not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetMinutesNominal
 * @summary getters do not mutate the receiver.
 * @covers FTimespan.get-minutes
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetMinutesNominal()
{
	FTimespan Span = FTimespan(2, 3, 4);
	return Span.GetMinutes() == 3;
}
/** @end */
/**
 * @begin get-seconds
 * @summary getters do not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetSecondsNominal
 * @summary getters do not mutate the receiver.
 * @covers FTimespan.get-seconds
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetSecondsNominal()
{
	FTimespan Span = FTimespan(2, 3, 4);
	return Span.GetSeconds() == 4;
}
/** @end */
/**
 * @begin get-ticks
 * @summary getters do not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetTicksNominal
 * @summary getters do not mutate the receiver.
 * @covers FTimespan.get-ticks
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTicksNominal()
{
	FTimespan Span = FTimespan::FromSeconds(1.0);
	FTimespan Zero = FTimespan::Zero();
	return Span.GetTicks() > 0 && Zero.GetTicks() == 0;
}
/** @end */
/**
 * @begin get-total-days
 * @summary not an empty optional.
 * @topic Unreal
 */
/**
 * @function ObserveGetTotalDaysNominal
 * @summary not an empty optional.
 * @covers FTimespan.get-total-days
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTotalDaysNominal()
{
	FTimespan Span = FTimespan::FromHours(24.0);
	return Span.GetTotalDays() == 1.0;
}
/** @end */
/**
 * @begin get-total-hours
 * @summary not an empty optional.
 * @topic Unreal
 */
/**
 * @function ObserveGetTotalHoursNominal
 * @summary not an empty optional.
 * @covers FTimespan.get-total-hours
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTotalHoursNominal()
{
	FTimespan Span = FTimespan::FromMinutes(90.0);
	return Span.GetTotalHours() == 1.5;
}
/** @end */
/**
 * @begin get-total-microseconds
 * @summary not an empty optional.
 * @topic Unreal
 */
/**
 * @function ObserveGetTotalMicrosecondsNominal
 * @summary not an empty optional.
 * @covers FTimespan.get-total-microseconds
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTotalMicrosecondsNominal()
{
	FTimespan Span = FTimespan::FromMilliseconds(1.0);
	return Span.GetTotalMicroseconds() == 1000.0;
}
/** @end */
/**
 * @begin get-total-milliseconds
 * @summary not an empty optional.
 * @topic Unreal
 */
/**
 * @function ObserveGetTotalMillisecondsNominal
 * @summary not an empty optional.
 * @covers FTimespan.get-total-milliseconds
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTotalMillisecondsNominal()
{
	FTimespan Span = FTimespan::FromSeconds(1.0);
	return Span.GetTotalMilliseconds() == 1000.0;
}
/** @end */
/**
 * @begin get-total-minutes
 * @summary not an empty optional.
 * @topic Unreal
 */
/**
 * @function ObserveGetTotalMinutesNominal
 * @summary not an empty optional.
 * @covers FTimespan.get-total-minutes
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTotalMinutesNominal()
{
	FTimespan Span = FTimespan::FromHours(1.0);
	return Span.GetTotalMinutes() == 60.0;
}
/** @end */
/**
 * @begin get-total-seconds
 * @summary not an empty optional.
 * @topic Unreal
 */
/**
 * @function ObserveGetTotalSecondsNominal
 * @summary not an empty optional.
 * @covers FTimespan.get-total-seconds
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetTotalSecondsNominal()
{
	FTimespan Span = FTimespan::FromMinutes(1.0);
	return Span.GetTotalSeconds() == 60.0;
}
/** @end */
/**
 * @begin is-zero
 * @summary not an empty optional.
 * @topic Unreal
 */
/**
 * @function ObserveIsZeroNominal
 * @summary not an empty optional.
 * @covers FTimespan.is-zero
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsZeroNominal()
{
	return FTimespan::Zero().IsZero() && !FTimespan::FromHours(1.0).IsZero();
}
/** @end */
/**
 * @begin max-value
 * @summary not an empty optional.
 * @topic Unreal
 */
/**
 * @function ObserveMaxValueNominal
 * @summary not an empty optional.
 * @covers FTimespan.max-value
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMaxValueNominal()
{
	FTimespan MaxValue = FTimespan::MaxValue();
	return MaxValue > FTimespan::Zero();
}
/** @end */
/**
 * @begin min-value
 * @summary not an empty optional.
 * @topic Unreal
 */
/**
 * @function ObserveMinValueNominal
 * @summary not an empty optional.
 * @covers FTimespan.min-value
 * @inputs FTimespan values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMinValueNominal()
{
	FTimespan MinValue = FTimespan::MinValue();
	return MinValue < FTimespan::Zero();
}
/** @end */
