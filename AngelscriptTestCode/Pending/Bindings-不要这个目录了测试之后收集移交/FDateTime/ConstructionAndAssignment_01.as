/**
 * @version v1
 * @summary Observe in-place FDateTime offset by FTimespan and string append of date-time text.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe in-place FDateTime offset by FTimespan and string append of date-time text.
 * @topic Baseline
 */
// and an empty FString seed.
// Expected observations: += one day increases GetDay. -= restores the original
// calendar day. Text += DateTime grows the string. The copied original remains
// independent until assigned.
// Boundary/ownership: += and -= mutate the date-time in place. FTimespan is
// not consumed. String append copies formatted text into the FString.

namespace TS_FDateTime_ConstructionAndAssignment_01
{
	bool Observe_AddAssign_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		FDateTime Original = DateTime;
		FTimespan OneDay = FTimespan::FromDays(1.0);
		DateTime += OneDay;
		DateTime += FTimespan::Zero();
		return DateTime.GetDay() == 3 && Original.GetDay() == 2;
	}

	bool Observe_SubtractAssign_Nominal()
	{
		FDateTime DateTime(2020, 1, 2, 3, 4, 5);
		FTimespan OneDay = FTimespan::FromDays(1.0);
		DateTime += OneDay;
		DateTime -= OneDay;
		FString Text = "when:";
		Text += DateTime;
		FString Empty = "";
		Empty += DateTime;
		return DateTime.GetDay() == 2 && DateTime.GetHour() == 3 && Text.Len() > 5 && Empty.Len() > 0;
	}
}
/** @end */
