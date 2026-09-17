/**
 * @version v1
 * @summary An &out TArray<int32> is filled then Shuffle permutes it.
 * @topic Containers
 *
 * FillByShufflePreservesMembership
 */
/**
 * @begin FillByShufflePreservesMembership
 * @summary An &out TArray<int32> is filled then Shuffle permutes it.
 * @topic Containers
 */
void FillByShufflePreservesMembership(TArray<int32>&out Result)
{
	Result.Add(10);
	Result.Add(20);
	Result.Add(30);
	Result.Shuffle();
}
/** @end */
