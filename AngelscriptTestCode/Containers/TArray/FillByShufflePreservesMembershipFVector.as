/**
 * @version v1
 * @summary An &out TArray<FVector> is filled then Shuffle permutes it.
 * @topic Containers
 *
 * FillByShufflePreservesMembershipFVector
 */
/**
 * @begin FillByShufflePreservesMembershipFVector
 * @summary An &out TArray<FVector> is filled then Shuffle permutes it.
 * @topic Containers
 */
void FillByShufflePreservesMembershipFVector(TArray<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Add(FVector(0.0f, 0.0f, 1.0f));
	Result.Shuffle();
}
/** @end */
