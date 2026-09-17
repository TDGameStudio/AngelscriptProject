/**
 * @version v1
 * @summary Sort() orders float values ascending and Sort(true) reverses that order.
 * @topic Containers
 *
 * SortAscendingFloat
 */
/**
 * @begin SortAscendingFloat
 * @summary Sort() orders float values ascending and Sort(true) reverses that order.
 * @topic Containers
 */
bool SortAscendingFloat()
{
	TArray<float> Values;
	Values.Add(3.0f);
	Values.Add(1.0f);
	Values.Add(2.0f);
	Values.Sort();
	bool bAscending = Values.Num() == 3 && Values[0] == 1.0f && Values[1] == 2.0f && Values[2] == 3.0f;
	Values.Sort(true);
	bool bDescending = Values[0] == 3.0f && Values[1] == 2.0f && Values[2] == 1.0f;
	Values.Sort(false);
	return bAscending && bDescending && Values[0] == 1.0f && Values[2] == 3.0f;
}
/** @end */
