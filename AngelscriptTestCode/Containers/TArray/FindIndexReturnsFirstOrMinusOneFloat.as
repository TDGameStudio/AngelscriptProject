/**
 * @version v1
 * @summary FindIndex returns the first matching float index or -1 when absent.
 * @topic Containers
 *
 * FindIndexReturnsFirstOrMinusOneFloat
 */
/**
 * @begin FindIndexReturnsFirstOrMinusOneFloat
 * @summary FindIndex returns the first matching float index or -1 when absent.
 * @topic Containers
 */
bool FindIndexReturnsFirstOrMinusOneFloat()
{
	TArray<float> Empty;
	TArray<float> Values;
	Values.Add(10.0f);
	Values.Add(20.0f);
	Values.Add(10.0f);
	return Empty.FindIndex(10.0f) == -1
		&& Values.FindIndex(10.0f) == 0
		&& Values.FindIndex(20.0f) == 1
		&& Values.FindIndex(99.0f) == -1;
}
/** @end */
