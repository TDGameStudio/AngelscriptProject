/**
 * @version v1
 * @summary Observe FDateTime calendar construction with defaulted time components and chronological ordering operators.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FDateTime calendar construction with defaulted time components and chronological ordering operators.
 * @topic Baseline
 */
// DateTime < Other;
// Inputs: (2020, 1, 2) with omitted time, (2020, 1, 2, 3, 4, 5, 6) explicit,
// and a later date for <, <=, >, >=.
// Expected observations: Omitted time components are zero. Explicit
// millisecond 6 is stored. Earlier < later is true; later < earlier is false.
// Boundary/ownership: Construction produces a value type. Ordering is
// chronological; the same binding supplies <=, >, and >=.

namespace TS_FDateTime_Behavior_01
{
	bool Observe_DateTime_Nominal()
	{
		FDateTime DateOnly(2020, 1, 2);
		FDateTime Explicit(2020, 1, 2, 3, 4, 5, 6);
		return DateOnly.GetHour() == 0 && DateOnly.GetMinute() == 0 && DateOnly.GetSecond() == 0 && DateOnly.GetMillisecond() == 0 && Explicit.GetHour() == 3 && Explicit.GetMillisecond() == 6;
	}

	bool Observe_Ordering_Nominal()
	{
		FDateTime Earlier(2020, 1, 2);
		FDateTime Later(2020, 1, 3);
		return Earlier < Later && Earlier <= Later && Later > Earlier && Later >= Earlier && !(Later < Earlier);
	}
}
/** @end */
