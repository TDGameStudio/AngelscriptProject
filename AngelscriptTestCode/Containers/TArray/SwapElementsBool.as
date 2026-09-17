/**
 * @version v1
 * @summary Swap(0, 2) exchanges bool ends while the middle value stays.
 * @topic Containers
 *
 * SwapElementsBool
 */
/**
 * @begin SwapElementsBool
 * @summary Swap(0, 2) exchanges bool ends while the middle value stays.
 * @topic Containers
 */
bool SwapElementsBool()
{
	TArray<bool> Values;
	Values.Add(false);
	Values.Add(true);
	Values.Add(true);
	Values.Swap(0, 2);
	Values.Swap(1, 1);
	return Values[0] == true && Values[2] == false && Values[1] == true && Values.Num() == 3;
}
/** @end */
