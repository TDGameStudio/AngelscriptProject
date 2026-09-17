/**
 * @version v1
 * @summary Default TOptional<FName> is unset and copy-independent.
 * @topic Containers
 *
 * EmptyConstructionFName
 */
/**
 * @begin EmptyConstructionFName
 * @summary Default TOptional<FName> is unset and copy-independent.
 * @topic Containers
 */
bool EmptyConstructionFName()
{
	TOptional<FName> First;
	TOptional<FName> Second;
	bool bDefaultUnset = !First.IsSet() && !Second.IsSet();
	First.Set(n"Red");
	return bDefaultUnset && First.IsSet() && !Second.IsSet();
}
/** @end */
