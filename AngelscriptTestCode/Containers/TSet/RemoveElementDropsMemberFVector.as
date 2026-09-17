/**
 * @version v1
 * @summary Remove of a present FVector member returns true and drops that member.
 * @topic Containers
 *
 * RemoveElementDropsMemberFVector
 */
/**
 * @begin RemoveElementDropsMemberFVector
 * @summary Remove of a present FVector member returns true and drops that member.
 * @topic Containers
 */
bool RemoveElementDropsMemberFVector()
{
	TSet<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	bool bRemoved = Values.Remove(FVector(1.0f, 0.0f, 0.0f));
	return bRemoved
		&& Values.Num() == 1
		&& Values.Contains(FVector(0.0f, 1.0f, 0.0f))
		&& !Values.Contains(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
