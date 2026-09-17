/**
 * @version v1
 * @summary A const&in TMap<int, FVector> reports assigned pairs.
 * @topic Containers
 *
 * ReadCopyAssignFVector
 */
/**
 * @begin ReadCopyAssignFVector
 * @summary A const&in TMap<int, FVector> reports assigned pairs.
 * @topic Containers
 */
bool ReadCopyAssignFVector(const TMap<int, FVector>&in Values)
{
	return Values.Num() == 3
		&& Values.Contains(1) && Values.Contains(2) && Values.Contains(3)
		&& Values[1].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[2].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Values[3].Equals(FVector(0.0f, 0.0f, 1.0f));
}
/** @end */
