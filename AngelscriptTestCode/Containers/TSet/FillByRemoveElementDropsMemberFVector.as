/**
 * @version v1
 * @summary An &out TSet<FVector> is filled then Remove drops one member.
 * @topic Containers
 *
 * FillByRemoveElementDropsMemberFVector
 */
/**
 * @begin FillByRemoveElementDropsMemberFVector
 * @summary An &out TSet<FVector> is filled then Remove drops one member.
 * @topic Containers
 */
void FillByRemoveElementDropsMemberFVector(TSet<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	Result.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.Remove(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
