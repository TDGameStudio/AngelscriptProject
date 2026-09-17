/**
 * @version v1
 * @summary Copy assignment copies FVector members and stays independent of later source mutation.
 * @topic Containers
 *
 * CopyAssignFVector
 */
/**
 * @begin CopyAssignFVector
 * @summary Copy assignment copies FVector members and stays independent of later source mutation.
 * @topic Containers
 */
bool CopyAssignFVector()
{
	TSet<FVector> Other;
	Other.Add(FVector(1.0f, 0.0f, 0.0f));
	Other.Add(FVector(0.0f, 1.0f, 0.0f));
	TSet<FVector> Values;
	Values = Other;
	Other.Add(FVector(0.0f, 0.0f, 1.0f));
	return Values.Num() == 2
		&& Values.Contains(FVector(1.0f, 0.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 1.0f, 0.0f))
		&& !Values.Contains(FVector(0.0f, 0.0f, 1.0f))
		&& Other.Num() == 3;
}
/** @end */
