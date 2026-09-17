/**
 * @version v1
 * @summary Sort() orders bool values ascending and Sort(true) reverses that order.
 * @topic Containers
 *
 * SortAscendingBool
 */
/**
 * @begin SortAscendingBool
 * @summary Sort() orders bool values ascending and Sort(true) reverses that order.
 * @topic Containers
 */
bool SortAscendingBool()
{
	TArray<bool> Values;
	Values.Add(true);
	Values.Add(false);
	Values.Add(true);
	Values.Sort();
	bool bAscending = Values.Num() == 3 && Values[0] == false && Values[1] == true && Values[2] == true;
	Values.Sort(true);
	bool bDescending = Values[0] == true && Values[1] == true && Values[2] == false;
	Values.Sort(false);
	return bAscending && bDescending && Values[0] == false && Values[2] == true;
}
/** @end */
