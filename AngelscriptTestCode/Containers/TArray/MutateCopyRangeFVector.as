/**
 * @version v1
 * @summary An &inout TArray<FVector> is overwritten in place by Copy.
 * @topic Containers
 *
 * MutateCopyRangeFVector
 */
/**
 * @begin MutateCopyRangeFVector
 * @summary An &inout TArray<FVector> is overwritten in place by Copy.
 * @topic Containers
 */
void MutateCopyRangeFVector(TArray<FVector>&inout Values)
{
	TArray<FVector> Source;
	Source.Add(FVector(1.0f, 0.0f, 0.0f));
	Source.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Copy(Source, 0, 2, 0);
}
/** @end */
