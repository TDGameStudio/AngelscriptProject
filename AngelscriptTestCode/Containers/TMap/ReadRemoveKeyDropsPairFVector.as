/**
 * @version v1
 * @summary A const&in TMap<int, FVector> reports the remaining pairs after Remove.
 * @topic Containers
 *
 * ReadRemoveKeyDropsPairFVector
 */
/**
 * @begin ReadRemoveKeyDropsPairFVector
 * @summary A const&in TMap<int, FVector> reports the remaining pairs after Remove.
 * @topic Containers
 */
bool ReadRemoveKeyDropsPairFVector(const TMap<int, FVector>&in Values)
{
	return Values.Num() == 2 && Values.Contains(1) && Values.Contains(3) && !Values.Contains(2);
}
/** @end */
