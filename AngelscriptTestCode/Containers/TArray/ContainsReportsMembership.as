/**
 * @version v1
 * @summary Contains is true for a present value and false for a missing one.
 * @topic Containers
 *
 * ContainsReportsMembership
 */
/**
 * @begin ContainsReportsMembership
 * @summary Contains is true for a present value and false for a missing one.
 * @topic Containers
 */
bool ContainsReportsMembership()
{
	TArray<int32> Empty;
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(1);
	TArray<FString> Texts;
	Texts.Add("Alpha");
	return !Empty.Contains(1) && Values.Contains(2) && !Values.Contains(9) && Texts.Contains("Alpha");
}
/** @end */
