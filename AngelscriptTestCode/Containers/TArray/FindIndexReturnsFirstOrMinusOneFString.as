/**
 * @version v1
 * @summary FindIndex returns the first matching FString index or -1 when absent.
 * @topic Containers
 *
 * FindIndexReturnsFirstOrMinusOneFString
 */
/**
 * @begin FindIndexReturnsFirstOrMinusOneFString
 * @summary FindIndex returns the first matching FString index or -1 when absent.
 * @topic Containers
 */
bool FindIndexReturnsFirstOrMinusOneFString()
{
	TArray<FString> Empty;
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("alpha");
	return Empty.FindIndex("alpha") == -1
		&& Values.FindIndex("alpha") == 0
		&& Values.FindIndex("beta") == 1
		&& Values.FindIndex("omega") == -1;
}
/** @end */
