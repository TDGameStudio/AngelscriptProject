// Purpose: Observe calendar and clock component queries, including out-param
// date decomposition.
// AS-facing API: FDateTime FDateTime.GetDate() const;
// void FDateTime.GetDate(int& OutYear, int& OutMonth, int& OutDay) const;
// int FDateTime.GetDay() const; int FDateTime.GetDayOfYear() const;
// int FDateTime.GetHour() const; int FDateTime.GetHour12() const;
// int FDateTime.GetMillisecond() const; int FDateTime.GetMinute() const;
// int FDateTime.GetMonth() const; int FDateTime.GetSecond() const;
// Inputs: 2020-02-01 13:04:05.006 as the positive state, default 2020-01-01
// 00:00:00 as the empty time-of-day, and out-params seeded to -1.
// Expected observations: GetDate clears time-of-day. Out-params become 2020,
// 2, 1. Hour 13 maps to Hour12 1. Default hour/minute/second are 0.
// Boundary/ownership: GetDate returns a new FDateTime. Out-params are written
// by the void overload and do not own the receiver.

namespace TS_FDateTime_Queries_01
{
	bool Observe_GetDate_Nominal()
	{
		FDateTime DateTime(2020, 2, 1, 13, 4, 5, 6);
		FDateTime DateOnly = DateTime.GetDate();
		int OutYear = -1;
		int OutMonth = -1;
		int OutDay = -1;
		DateTime.GetDate(OutYear, OutMonth, OutDay);
		return DateOnly.GetHour() == 0 && DateOnly.GetMinute() == 0 && DateOnly.GetDay() == 1 && OutYear == 2020 && OutMonth == 2 && OutDay == 1;
	}

	bool Observe_GetDay_Nominal()
	{
		FDateTime DateTime(2020, 2, 1);
		return DateTime.GetDay() == 1;
	}

	bool Observe_GetDayOfYear_Nominal()
	{
		FDateTime DateTime(2020, 2, 1);
		return DateTime.GetDayOfYear() == 32;
	}

	bool Observe_GetHour_Nominal()
	{
		FDateTime Afternoon(2020, 2, 1, 13);
		FDateTime Midnight(2020, 2, 1);
		return Afternoon.GetHour() == 13 && Midnight.GetHour() == 0;
	}

	bool Observe_GetHour12_Nominal()
	{
		FDateTime Afternoon(2020, 2, 1, 13);
		return Afternoon.GetHour12() == 1;
	}

	bool Observe_GetMillisecond_Nominal()
	{
		FDateTime DateTime(2020, 2, 1, 13, 4, 5, 6);
		return DateTime.GetMillisecond() == 6;
	}

	bool Observe_GetMinute_Nominal()
	{
		FDateTime DateTime(2020, 2, 1, 13, 4, 5);
		return DateTime.GetMinute() == 4;
	}

	bool Observe_GetMonth_Nominal()
	{
		FDateTime DateTime(2020, 2, 1);
		return DateTime.GetMonth() == 2;
	}

	bool Observe_GetSecond_Nominal()
	{
		FDateTime DateTime(2020, 2, 1, 13, 4, 5);
		return DateTime.GetSecond() == 5;
	}
}
