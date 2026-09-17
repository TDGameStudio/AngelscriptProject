/**
 * @version v1
 * @summary Default TOptional<bool> is unset and copy-independent.
 * @topic Containers
 *
 * EmptyConstructionBool
 */
/**
 * @begin EmptyConstructionBool
 * @summary Default TOptional<bool> is unset and copy-independent.
 * @topic Containers
 */
bool EmptyConstructionBool()
{
	TOptional<bool> First;
	TOptional<bool> Second;
	bool bDefaultUnset = !First.IsSet() && !Second.IsSet();
	First.Set(true);
	bool bCopyIndependent = First.IsSet() && !Second.IsSet();
	TOptional<bool> StoredFalse;
	StoredFalse.Set(false);
	TOptional<bool> StillUnset;
	return bDefaultUnset && bCopyIndependent && StoredFalse.IsSet() && StoredFalse.GetValue() == false
		&& StillUnset != StoredFalse;
}
/** @end */
