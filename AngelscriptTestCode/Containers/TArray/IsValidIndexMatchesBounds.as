/**
 * @version v1
 * @summary IsValidIndex is true only for indices in [0, Num).
 * @topic Containers
 *
 * IsValidIndexMatchesBounds
 */
/**
 * @begin IsValidIndexMatchesBounds
 * @summary IsValidIndex is true only for indices in [0, Num).
 * @topic Containers
 */
bool IsValidIndexMatchesBounds()
{
	TArray<int32> Empty;
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	Values.Add(30);
	return !Empty.IsValidIndex(0) && !Empty.IsValidIndex(-1) && Values.IsValidIndex(0) && Values.IsValidIndex(2) && !Values.IsValidIndex(3);
}
/** @end */
