/**
 * @version v1
 * @summary A const&in TArray<float> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 *
 * ReadRemoveSwapFloat
 */
/**
 * @begin ReadRemoveSwapFloat
 * @summary A const&in TArray<float> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 */
bool ReadRemoveSwapFloat(const TArray<float>&in Values)
{
	return Values.Num() == 3
		&& !Values.Contains(2.0f)
		&& Values.Contains(1.0f)
		&& Values.Contains(3.0f)
		&& Values.Contains(4.0f);
}
/** @end */
