/**
 * @version v1
 * @summary Sort() orders FString values ascending and Sort(true) reverses that order.
 * @topic Containers
 *
 * SortAscendingFString
 */
/**
 * @begin SortAscendingFString
 * @summary Sort() orders FString values ascending and Sort(true) reverses that order.
 * @topic Containers
 */
bool SortAscendingFString()
{
	TArray<FString> Values;
	Values.Add("c");
	Values.Add("a");
	Values.Add("b");
	Values.Sort();
	bool bAscending = Values.Num() == 3 && Values[0] == "a" && Values[1] == "b" && Values[2] == "c";
	Values.Sort(true);
	bool bDescending = Values[0] == "c" && Values[1] == "b" && Values[2] == "a";
	Values.Sort(false);
	return bAscending && bDescending && Values[0] == "a" && Values[2] == "c";
}
/** @end */
