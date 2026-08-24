// Purpose: Observe FDateTime calendar helpers and current-time factories.
// AS-facing API: int FDateTime::DaysInMonth(int Year, int Month);
// int FDateTime::DaysInYear(int Year); FDateTime FDateTime::Now();
// FDateTime FDateTime::UtcNow();
// Inputs: February 2020 vs 2019, year 2020 vs 2019, and the live Now/UtcNow
// clocks.
// Expected observations: Leap February has 29 days, common February 28.
// Leap year has 366 days. Now and UtcNow are both greater than MinValue.
// Boundary/ownership: Now/UtcNow sample clocks; they do not allocate calendar
// objects beyond the returned value type.

namespace TS_FDateTime_NamespaceAndGlobalFunctions_01
{
	bool Observe_DaysInMonth_Nominal()
	{
		int LeapFebruary = FDateTime::DaysInMonth(2020, 2);
		int CommonFebruary = FDateTime::DaysInMonth(2019, 2);
		int January = FDateTime::DaysInMonth(2020, 1);
		return LeapFebruary == 29 && CommonFebruary == 28 && January == 31;
	}

	bool Observe_DaysInYear_Nominal()
	{
		int LeapYear = FDateTime::DaysInYear(2020);
		int CommonYear = FDateTime::DaysInYear(2019);
		return LeapYear == 366 && CommonYear == 365;
	}

	bool Observe_Now_Nominal()
	{
		FDateTime Now = FDateTime::Now();
		return Now > FDateTime::MinValue();
	}

	bool Observe_UtcNow_Nominal()
	{
		FDateTime UtcNow = FDateTime::UtcNow();
		return UtcNow > FDateTime::MinValue();
	}
}
