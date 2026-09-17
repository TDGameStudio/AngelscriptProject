/**
 * @version v1
 * @summary Observe year, morning/afternoon, ticks, leap-year, and min/max FDateTime queries.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe year, morning/afternoon, ticks, leap-year, and min/max FDateTime queries.
 * @topic Baseline
 */
// bool FDateTime.IsMorning() const; int64 FDateTime.GetTicks() const;
// bool FDateTime::IsLeapYear(int Year); FDateTime FDateTime::MinValue();
// FDateTime FDateTime::MaxValue();
// Inputs: 2020-02-01 13:00 as afternoon, 2020-02-01 09:00 as morning, years
// 2020 and 2019, and the static min/max sentinels.
// Expected observations: 13:00 is afternoon not morning. 09:00 is morning.
// 2020 is a leap year, 2019 is not. MinValue is less than MaxValue. Ticks of
// a later date are greater.
// Boundary/ownership: MinValue/MaxValue are sentinels, not current time.
// IsLeapYear does not require a constructed FDateTime instance.

namespace TS_FDateTime_Queries_02
{
	bool Observe_GetYear_Nominal()
	{
		FDateTime DateTime(2020, 2, 1);
		return DateTime.GetYear() == 2020;
	}

	bool Observe_IsAfternoon_Nominal()
	{
		FDateTime Afternoon(2020, 2, 1, 13);
		FDateTime Morning(2020, 2, 1, 9);
		return Afternoon.IsAfternoon() && !Morning.IsAfternoon();
	}

	bool Observe_IsMorning_Nominal()
	{
		FDateTime Afternoon(2020, 2, 1, 13);
		FDateTime Morning(2020, 2, 1, 9);
		return Morning.IsMorning() && !Afternoon.IsMorning();
	}

	bool Observe_GetTicks_Nominal()
	{
		FDateTime Earlier(2020, 2, 1);
		FDateTime Later(2020, 2, 2);
		return Later.GetTicks() > Earlier.GetTicks();
	}

	bool Observe_IsLeapYear_Nominal()
	{
		return FDateTime::IsLeapYear(2020) && !FDateTime::IsLeapYear(2019);
	}

	bool Observe_MinValue_Nominal()
	{
		FDateTime MinValue = FDateTime::MinValue();
		FDateTime Sample(2020, 1, 1);
		return MinValue < Sample;
	}

	bool Observe_MaxValue_Nominal()
	{
		FDateTime MaxValue = FDateTime::MaxValue();
		FDateTime MinValue = FDateTime::MinValue();
		return MaxValue > MinValue;
	}
}
/** @end */
