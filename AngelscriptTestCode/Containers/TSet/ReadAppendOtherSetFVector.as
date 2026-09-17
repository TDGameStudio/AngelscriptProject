/**
 * @version v1
 * @summary A const&in TSet<FVector> reports Append membership.
 * @topic Containers
 *
 * ReadAppendOtherSetFVector
 */
/**
 * @begin ReadAppendOtherSetFVector
 * @summary A const&in TSet<FVector> reports Append membership.
 * @topic Containers
 */
bool ReadAppendOtherSetFVector(const TSet<FVector>&in Values)
{
	return Values.Num() == 3
		&& Values.Contains(FVector(1.0f, 0.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 0.0f, 1.0f))
		&& Values.Contains(FVector(1.0f, 1.0f, 0.0f));
}
/** @end */
