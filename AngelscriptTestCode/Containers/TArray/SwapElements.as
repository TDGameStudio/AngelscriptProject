/**
 * @version v1
 * @summary Swap(0, 2) exchanges 10 and 30 while the middle value stays.
 * @topic Containers
 *
 * SwapElements
 */
/**
 * @begin SwapElements
 * @summary Swap(0, 2) exchanges 10 and 30 while the middle value stays.
 * @topic Containers
 */
bool SwapElements()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	Values.Add(30);
	Values.Swap(0, 2);
	Values.Swap(1, 1);
	return Values[0] == 30 && Values[2] == 10 && Values[1] == 20 && Values.Num() == 3;
}
/** @end */
