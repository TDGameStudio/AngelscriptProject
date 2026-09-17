/**
 * @version v1
 * @summary A const&in TArray<float> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 *
 * ReadRemoveAtSwapFloat
 */
/**
 * @begin ReadRemoveAtSwapFloat
 * @summary A const&in TArray<float> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 */
bool ReadRemoveAtSwapFloat(const TArray<float>&in Values)
{
	return Values.Num() == 3
		&& !Values.Contains(1.0f)
		&& Values.Contains(2.0f)
		&& Values.Contains(3.0f)
		&& Values.Contains(4.0f);
}
/** @end */
