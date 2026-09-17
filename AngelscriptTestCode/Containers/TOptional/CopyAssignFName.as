/**
 * @version v1
 * @summary Copy assignment copies TOptional<FName> set state and value without sharing storage.
 * @topic Containers
 *
 * CopyAssignFName
 */
/**
 * @begin CopyAssignFName
 * @summary Copy assignment copies TOptional<FName> set state and value without sharing storage.
 * @topic Containers
 */
bool CopyAssignFName()
{
	TOptional<FName> UnsetRight;
	TOptional<FName> UnsetLeft;
	UnsetLeft = UnsetRight;
	bool bCopiedUnset = !UnsetLeft.IsSet() && !UnsetRight.IsSet();

	TOptional<FName> SetRight;
	SetRight.Set(n"Red");
	TOptional<FName> SetLeft;
	SetLeft = SetRight;
	bool bCopiedSet = SetLeft.IsSet() && SetLeft.GetValue() == n"Red";
	SetRight.Set(n"Green");
	bool bCopyIndependent = SetLeft.GetValue() == n"Red" && SetRight.GetValue() == n"Green";

	return bCopiedUnset && bCopiedSet && bCopyIndependent;
}
/** @end */
