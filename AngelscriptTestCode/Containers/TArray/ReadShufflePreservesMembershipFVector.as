/**
 * @version v1
 * @summary A const&in TArray<FVector> reports Shuffle membership.
 * @topic Containers
 *
 * ReadShufflePreservesMembershipFVector
 */
/**
 * @begin ReadShufflePreservesMembershipFVector
 * @summary A const&in TArray<FVector> reports Shuffle membership.
 * @topic Containers
 */
bool ReadShufflePreservesMembershipFVector(const TArray<FVector>&in Values)
{
	return Values.Num() == 3
		&& Values.Contains(FVector(1.0f, 0.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 1.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
