/**
 * @version v1
 * @summary A const&in TArray<int32> reports Shuffle membership.
 * @topic Containers
 *
 * ReadShufflePreservesMembership
 */
/**
 * @begin ReadShufflePreservesMembership
 * @summary A const&in TArray<int32> reports Shuffle membership.
 * @topic Containers
 */
bool ReadShufflePreservesMembership(const TArray<int32>&in Values)
{
	return Values.Num() == 3 && Values.Contains(10) && Values.Contains(20) && Values.Contains(30);
}
/** @end */
