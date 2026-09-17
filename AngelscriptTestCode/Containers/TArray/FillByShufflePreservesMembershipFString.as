/**
 * @version v1
 * @summary An &out TArray<FString> is filled then Shuffle permutes it.
 * @topic Containers
 *
 * FillByShufflePreservesMembershipFString
 */
/**
 * @begin FillByShufflePreservesMembershipFString
 * @summary An &out TArray<FString> is filled then Shuffle permutes it.
 * @topic Containers
 */
void FillByShufflePreservesMembershipFString(TArray<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("beta");
	Result.Add("gamma");
	Result.Shuffle();
}
/** @end */
