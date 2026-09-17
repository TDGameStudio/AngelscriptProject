/**
 * @version v1
 * @summary A const&in TSet<FVector> reports membership after Remove.
 * @topic Containers
 *
 * ReadRemoveElementDropsMemberFVector
 */
/**
 * @begin ReadRemoveElementDropsMemberFVector
 * @summary A const&in TSet<FVector> reports membership after Remove.
 * @topic Containers
 */
bool ReadRemoveElementDropsMemberFVector(const TSet<FVector>&in Values)
{
	return Values.Num() == 1
		&& Values.Contains(FVector(0.0f, 1.0f, 0.0f))
		&& !Values.Contains(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
