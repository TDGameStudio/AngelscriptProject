/**
 * @version v1
 * @summary A const&in TArray<float> reports the array after RemoveAt shifted later elements.
 * @topic Containers
 *
 * ReadRemoveAtIndexFloat
 */
/**
 * @begin ReadRemoveAtIndexFloat
 * @summary A const&in TArray<float> reports the array after RemoveAt shifted later elements.
 * @topic Containers
 */
bool ReadRemoveAtIndexFloat(const TArray<float>&in Values)
{
	return Values.Num() == 2 && Values[0] == 2.0f && Values[1] == 3.0f;
}
/** @end */
