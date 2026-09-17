/**
 * @version v1
 * @summary An &out TArray<float> is filled then Shuffle permutes it.
 * @topic Containers
 *
 * FillByShufflePreservesMembershipFloat
 */
/**
 * @begin FillByShufflePreservesMembershipFloat
 * @summary An &out TArray<float> is filled then Shuffle permutes it.
 * @topic Containers
 */
void FillByShufflePreservesMembershipFloat(TArray<float>&out Result)
{
	Result.Add(10.0f);
	Result.Add(20.0f);
	Result.Add(30.0f);
	Result.Shuffle();
}
/** @end */
