/**
 * @version v1
 * @summary Copy assignment copies TOptional<FVector> set state and value without sharing storage.
 * @topic Containers
 *
 * CopyAssignFVector
 */
/**
 * @begin CopyAssignFVector
 * @summary Copy assignment copies TOptional<FVector> set state and value without sharing storage.
 * @topic Containers
 */
bool CopyAssignFVector()
{
	TOptional<FVector> UnsetRight;
	TOptional<FVector> UnsetLeft;
	UnsetLeft = UnsetRight;
	bool bCopiedUnset = !UnsetLeft.IsSet() && !UnsetRight.IsSet();

	TOptional<FVector> SetRight;
	SetRight.Set(FVector(1.0f, 0.0f, 0.0f));
	TOptional<FVector> SetLeft;
	SetLeft = SetRight;
	bool bCopiedSet = SetLeft.IsSet() && SetLeft.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f));
	SetRight.Set(FVector(0.0f, 1.0f, 0.0f));
	bool bCopyIndependent = SetLeft.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f))
		&& SetRight.GetValue().Equals(FVector(0.0f, 1.0f, 0.0f));

	return bCopiedUnset && bCopiedSet && bCopyIndependent;
}
/** @end */
