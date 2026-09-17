/**
 * @version v1
 * @summary A const&in TArray<float> reports the array after RemoveSingle kept later order.
 * @topic Containers
 *
 * ReadRemoveSinglePreservesOrderFloat
 */
/**
 * @begin ReadRemoveSinglePreservesOrderFloat
 * @summary A const&in TArray<float> reports the array after RemoveSingle kept later order.
 * @topic Containers
 */
bool ReadRemoveSinglePreservesOrderFloat(const TArray<float>&in Values)
{
	return Values.Num() == 3 && Values[0] == 1.0f && Values[1] == 2.0f && Values[2] == 3.0f;
}
/** @end */
