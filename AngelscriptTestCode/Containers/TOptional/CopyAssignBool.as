/**
 * @version v1
 * @summary Copy assignment copies TOptional<bool> set state and value without sharing storage.
 * @topic Containers
 *
 * CopyAssignBool
 */
/**
 * @begin CopyAssignBool
 * @summary Copy assignment copies TOptional<bool> set state and value without sharing storage.
 * @topic Containers
 */
bool CopyAssignBool()
{
	TOptional<bool> UnsetRight;
	TOptional<bool> UnsetLeft;
	UnsetLeft = UnsetRight;
	bool bCopiedUnset = !UnsetLeft.IsSet() && !UnsetRight.IsSet();

	TOptional<bool> SetRight;
	SetRight.Set(false);
	TOptional<bool> SetLeft;
	SetLeft = SetRight;
	bool bCopiedSet = SetLeft.IsSet() && SetLeft.GetValue() == false;
	SetRight.Set(true);
	bool bCopyIndependent = SetLeft.GetValue() == false && SetRight.GetValue() == true;

	return bCopiedUnset && bCopiedSet && bCopyIndependent;
}
/** @end */
