/**
 * @version v1
 * @summary Swap(0, 2) exchanges float ends while the middle value stays.
 * @topic Containers
 *
 * SwapElementsFloat
 */
/**
 * @begin SwapElementsFloat
 * @summary Swap(0, 2) exchanges float ends while the middle value stays.
 * @topic Containers
 */
bool SwapElementsFloat()
{
	TArray<float> Values;
	Values.Add(10.0f);
	Values.Add(20.0f);
	Values.Add(30.0f);
	Values.Swap(0, 2);
	Values.Swap(1, 1);
	return Values[0] == 30.0f && Values[2] == 10.0f && Values[1] == 20.0f && Values.Num() == 3;
}
/** @end */
