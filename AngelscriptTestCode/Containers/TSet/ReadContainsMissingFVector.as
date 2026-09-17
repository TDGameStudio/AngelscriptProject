/**
 * @version v1
 * @summary A const&in TSet<FVector> reports Contains false for an absent member.
 * @topic Containers
 *
 * ReadContainsMissingFVector
 */
/**
 * @begin ReadContainsMissingFVector
 * @summary A const&in TSet<FVector> reports Contains false for an absent member.
 * @topic Containers
 */
bool ReadContainsMissingFVector(const TSet<FVector>&in Values)
{
	return !Values.Contains(FVector(9.0f, 9.0f, 9.0f)) && Values.Contains(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
