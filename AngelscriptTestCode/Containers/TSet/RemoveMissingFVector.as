/**
 * @version v1
 * @summary Remove of an absent FVector member returns false and does not throw.
 * @topic Containers
 *
 * RemoveMissingFVector
 */
/**
 * @begin RemoveMissingFVector
 * @summary Remove of an absent FVector member returns false and does not throw.
 * @topic Containers
 */
bool RemoveMissingFVector()
{
	TSet<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	return !Values.Remove(FVector(9.0f, 9.0f, 9.0f))
		&& Values.Num() == 1
		&& Values.Contains(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
