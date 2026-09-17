/**
 * @version v1
 * @summary FindIndex returns the first matching bool index on an empty or filled array.
 * @topic Containers
 *
 * FindIndexReturnsFirstOrMinusOneBool
 */
/**
 * @begin FindIndexReturnsFirstOrMinusOneBool
 * @summary FindIndex returns the first matching bool index on an empty or filled array.
 * @topic Containers
 */
bool FindIndexReturnsFirstOrMinusOneBool()
{
	TArray<bool> Empty;
	TArray<bool> Values;
	Values.Add(false);
	Values.Add(true);
	Values.Add(false);
	return Empty.FindIndex(true) == -1 && Values.FindIndex(false) == 0 && Values.FindIndex(true) == 1;
}
/** @end */
