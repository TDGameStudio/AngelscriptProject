/**
 * @version v1
 * @summary Copy assignment copies set state and value without sharing storage.
 * @topic Containers
 *
 * CopyAssign
 */
/**
 * @begin CopyAssign
 * @summary Copy assignment copies set state and value without sharing storage.
 * @topic Containers
 */
bool CopyAssign()
{
	TOptional<int32> UnsetRight;
	TOptional<int32> UnsetLeft;
	UnsetLeft = UnsetRight;
	bool bCopiedUnset = !UnsetLeft.IsSet() && !UnsetRight.IsSet();

	TOptional<int32> SetRight;
	SetRight.Set(7);
	TOptional<int32> SetLeft;
	SetLeft = SetRight;
	bool bCopiedSet = SetLeft.IsSet() && SetLeft.GetValue() == 7;
	SetRight.Set(9);
	bool bCopyIndependent = SetLeft.GetValue() == 7 && SetRight.GetValue() == 9;

	return bCopiedUnset && bCopiedSet && bCopyIndependent;
}
/** @end */
