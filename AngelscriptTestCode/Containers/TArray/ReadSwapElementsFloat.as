/**
 * @version v1
 * @summary A const&in TArray<float> reports Swap order.
 * @topic Containers
 *
 * ReadSwapElementsFloat
 */
/**
 * @begin ReadSwapElementsFloat
 * @summary A const&in TArray<float> reports Swap order.
 * @topic Containers
 */
bool ReadSwapElementsFloat(const TArray<float>&in Values)
{
	return Values.Num() == 3 && Values[0] == 30.0f && Values[1] == 20.0f && Values[2] == 10.0f;
}
/** @end */
