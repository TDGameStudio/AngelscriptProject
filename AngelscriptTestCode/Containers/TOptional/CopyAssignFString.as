/**
 * @version v1
 * @summary Copy assignment copies TOptional<FString> set state and value without sharing storage.
 * @topic Containers
 *
 * CopyAssignFString
 */
/**
 * @begin CopyAssignFString
 * @summary Copy assignment copies TOptional<FString> set state and value without sharing storage.
 * @topic Containers
 */
bool CopyAssignFString()
{
	TOptional<FString> UnsetRight;
	TOptional<FString> UnsetLeft;
	UnsetLeft = UnsetRight;
	bool bCopiedUnset = !UnsetLeft.IsSet() && !UnsetRight.IsSet();

	TOptional<FString> SetRight;
	SetRight.Set("alpha");
	TOptional<FString> SetLeft;
	SetLeft = SetRight;
	bool bCopiedSet = SetLeft.IsSet() && SetLeft.GetValue() == "alpha";
	SetRight.Set("beta");
	bool bCopyIndependent = SetLeft.GetValue() == "alpha" && SetRight.GetValue() == "beta";

	return bCopiedUnset && bCopiedSet && bCopyIndependent;
}
/** @end */
