/**
 * @version v1
 * @summary FindIndex returns the first matching index or -1 when the value is absent.
 * @topic Containers
 *
 * FindIndexReturnsFirstOrMinusOne
 */
/**
 * @begin FindIndexReturnsFirstOrMinusOne
 * @summary FindIndex returns the first matching index or -1 when the value is absent.
 * @topic Containers
 */
bool FindIndexReturnsFirstOrMinusOne()
{
	TArray<int32> Empty;
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	Values.Add(10);
	return Empty.FindIndex(10) == -1 && Values.FindIndex(10) == 0 && Values.FindIndex(20) == 1 && Values.FindIndex(99) == -1;
}
/** @end */
