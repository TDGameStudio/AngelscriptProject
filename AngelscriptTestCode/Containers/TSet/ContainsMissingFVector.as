/**
 * @version v1
 * @summary Contains is false for an FVector member that was never added.
 * @topic Containers
 *
 * ContainsMissingFVector
 */
/**
 * @begin ContainsMissingFVector
 * @summary Contains is false for an FVector member that was never added.
 * @topic Containers
 */
bool ContainsMissingFVector()
{
	TSet<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	return !Values.Contains(FVector(9.0f, 9.0f, 9.0f)) && Values.Contains(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
