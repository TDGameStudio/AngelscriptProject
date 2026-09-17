/**
 * @version v1
 * @summary RemoveAt drops the indexed FString and shifts later elements down.
 * @topic Containers
 *
 * RemoveAtIndexFString
 */
/**
 * @begin RemoveAtIndexFString
 * @summary RemoveAt drops the indexed FString and shifts later elements down.
 * @topic Containers
 */
bool RemoveAtIndexFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("gamma");
	Values.RemoveAt(1);
	return Values.Num() == 2 && Values[0] == "alpha" && Values[1] == "gamma";
}
/** @end */
