/**
 * @version v1
 * @summary An &inout TSet<FVector> receives Append of another set.
 * @topic Containers
 *
 * MutateAppendOtherSetFVector
 */
/**
 * @begin MutateAppendOtherSetFVector
 * @summary An &inout TSet<FVector> receives Append of another set.
 * @topic Containers
 */
void MutateAppendOtherSetFVector(TSet<FVector>&inout Values)
{
	TSet<FVector> Other;
	Other.Add(FVector(0.0f, 0.0f, 1.0f));
	Other.Add(FVector(1.0f, 1.0f, 0.0f));
	Values.Append(Other);
}
/** @end */
