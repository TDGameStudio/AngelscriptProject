/**
 * @version v1
 * @summary A const&in TArray<float> reports Add insertion order.
 * @topic Containers
 *
 * ReadAddOrderFloat
 */
/**
 * @begin ReadAddOrderFloat
 * @summary A const&in TArray<float> reports Add insertion order.
 * @topic Containers
 */
bool ReadAddOrderFloat(const TArray<float>&in Values)
{
	return Values.Num() == 3 && Values[0] == 10.0f && Values[1] == 20.0f && Values[2] == 30.0f;
}
/** @end */
