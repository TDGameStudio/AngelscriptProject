/**
 * @version v1
 * @summary A const&in TOptional<UObject> copies by assignment and compares equal.
 * @topic Containers
 *
 * ReadCopyAssignUObject
 */
/**
 * @begin ReadCopyAssignUObject
 * @summary A const&in TOptional<UObject> copies by assignment and compares equal.
 * @topic Containers
 */
bool ReadCopyAssignUObject(const TOptional<UObject>&in Value)
{
	TOptional<UObject> Copy;
	Copy = Value;
	return Copy.IsSet() && Copy == Value && Copy.GetValue() != nullptr;
}
/** @end */
