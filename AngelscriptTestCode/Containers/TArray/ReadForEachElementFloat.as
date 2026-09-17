/**
 * @version v1
 * @summary A const&in TArray<float> is summed by range-for.
 * @topic Containers
 *
 * ReadForEachElementFloat
 */
/**
 * @begin ReadForEachElementFloat
 * @summary A const&in TArray<float> is summed by range-for.
 * @topic Containers
 */
bool ReadForEachElementFloat(const TArray<float>&in Values)
{
	float Sum = 0.0f;
	for (const float& Value : Values)
	{
		Sum += Value;
	}
	return Sum == 60.0f;
}
/** @end */
