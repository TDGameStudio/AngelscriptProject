/**
 * @version v1
 * @summary An &inout TArray<float> has its first matching element deleted by RemoveSingle.
 * @topic Containers
 *
 * MutateRemoveSinglePreservesOrderFloat
 */
/**
 * @begin MutateRemoveSinglePreservesOrderFloat
 * @summary An &inout TArray<float> has its first matching element deleted by RemoveSingle.
 * @topic Containers
 */
void MutateRemoveSinglePreservesOrderFloat(TArray<float>&inout Values)
{
	Values.RemoveSingle(2.0f);
}
/** @end */
