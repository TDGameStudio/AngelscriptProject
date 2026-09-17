/**
 * @version v1
 * @summary Sort() orders int32 values ascending and Sort(true) reverses that order.
 * @topic Containers
 *
 * SortAscending
 */
/**
 * @begin SortAscending
 * @summary Sort() orders int32 values ascending and Sort(true) reverses that order.
 * @topic Containers
 */
bool SortAscending()
{
	TArray<int32> Values;
	Values.Add(3);
	Values.Add(1);
	Values.Add(2);
	Values.Sort();
	bool bAscending = Values.Num() == 3 && Values[0] == 1 && Values[1] == 2 && Values[2] == 3;
	Values.Sort(true);
	bool bDescending = Values[0] == 3 && Values[1] == 2 && Values[2] == 1;
	Values.Sort(false);
	return bAscending && bDescending && Values[0] == 1 && Values[2] == 3;
}
/** @end */
