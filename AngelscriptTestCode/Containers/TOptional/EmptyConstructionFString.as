/**
 * @version v1
 * @summary Default TOptional<FString> is unset and copy-independent.
 * @topic Containers
 *
 * EmptyConstructionFString
 */
/**
 * @begin EmptyConstructionFString
 * @summary Default TOptional<FString> is unset and copy-independent.
 * @topic Containers
 */
bool EmptyConstructionFString()
{
	TOptional<FString> First;
	TOptional<FString> Second;
	bool bDefaultUnset = !First.IsSet() && !Second.IsSet();
	First.Set("alpha");
	bool bCopyIndependent = First.IsSet() && !Second.IsSet();
	TOptional<FString> EmptyText;
	EmptyText.Set("");
	return bDefaultUnset && bCopyIndependent && EmptyText.IsSet() && EmptyText.GetValue() == "";
}
/** @end */
