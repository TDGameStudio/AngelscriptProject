/**
 * @version v1
 * @summary Observe value-returning FDateTime equality, timespan offset, and string concatenation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe value-returning FDateTime equality, timespan offset, and string concatenation.
 * @topic Baseline
 */
// DateTime - Timespan; Text + DateTime;
// Inputs: Matching 2020-01-02 values, a later 2020-01-03 value, one-day
// timespan, and prefix "when:".
// Expected observations: Equal calendar values compare true. Adding one day
// yields GetDay 3. Subtracting two dates yields a positive timespan. Text +
// DateTime returns a longer string without mutating the prefix.
// Boundary/ownership: These operators return new values. += is the mutating
// counterpart and is not used here.

namespace TS_FDateTime_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FDateTime Left(2020, 1, 2, 3, 4, 5);
		FDateTime Right(2020, 1, 2, 3, 4, 5);
		FDateTime Later(2020, 1, 3);
		return Left == Right && !(Left == Later);
	}

	bool Observe_Addition_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		FTimespan OneDay = FTimespan::FromDays(1.0);
		FDateTime Offset = DateTime + OneDay;
		FString Prefix = "when:";
		FString Combined = Prefix + DateTime;
		return Offset.GetDay() == 3 && DateTime.GetDay() == 2 && Combined.Len() > Prefix.Len() && Prefix == "when:";
	}

	bool Observe_Subtraction_Nominal()
	{
		FDateTime Start(2020, 1, 2);
		FDateTime End(2020, 1, 3);
		FTimespan Delta = End - Start;
		FTimespan OneHour = FTimespan::FromHours(1.0);
		FDateTime Back = End - OneHour;
		return Delta.GetDays() == 1 && Back < End;
	}
}
/** @end */
