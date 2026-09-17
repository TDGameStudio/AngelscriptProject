/**
 * @version v1
 * @summary An &out TArray<bool> is filled then Shuffle permutes it.
 * @topic Containers
 *
 * FillByShufflePreservesMembershipBool
 */
/**
 * @begin FillByShufflePreservesMembershipBool
 * @summary An &out TArray<bool> is filled then Shuffle permutes it.
 * @topic Containers
 */
void FillByShufflePreservesMembershipBool(TArray<bool>&out Result)
{
	Result.Add(true);
	Result.Add(false);
	Result.Add(true);
	Result.Shuffle();
}
/** @end */
