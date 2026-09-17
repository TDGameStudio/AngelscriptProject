/**
 * @version v1
 * @summary An &inout TArray<FVector> receives Append of another array.
 * @topic Containers
 *
 * MutateAppendOtherArrayFVector
 */
/**
 * @begin MutateAppendOtherArrayFVector
 * @summary An &inout TArray<FVector> receives Append of another array.
 * @topic Containers
 */
void MutateAppendOtherArrayFVector(TArray<FVector>&inout Values)
{
	TArray<FVector> Other;
	Other.Add(FVector(0.0f, 1.0f, 0.0f));
	Other.Add(FVector(0.0f, 0.0f, 1.0f));
	Values.Append(Other);
}
/** @end */
