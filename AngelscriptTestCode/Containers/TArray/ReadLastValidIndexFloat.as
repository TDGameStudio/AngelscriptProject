/**
 * @version v1
 * @summary A const&in TArray<float> reports Last() and Last(1) from the end.
 * @topic Containers
 *
 * ReadLastValidIndexFloat
 */
/**
 * @begin ReadLastValidIndexFloat
 * @summary A const&in TArray<float> reports Last() and Last(1) from the end.
 * @topic Containers
 */
bool ReadLastValidIndexFloat(const TArray<float>&in Values)
{
	return Values.Last() == 30.0f && Values.Last(1) == 20.0f && Values.Last(2) == 10.0f;
}
/** @end */
