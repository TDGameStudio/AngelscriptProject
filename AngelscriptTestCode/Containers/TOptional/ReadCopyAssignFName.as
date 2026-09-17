/**
 * @version v1
 * @summary A const&in TOptional<FName> copies by assignment and compares equal.
 * @topic Containers
 *
 * ReadCopyAssignFName
 */
/**
 * @begin ReadCopyAssignFName
 * @summary A const&in TOptional<FName> copies by assignment and compares equal.
 * @topic Containers
 */
bool ReadCopyAssignFName(const TOptional<FName>&in Value)
{
	TOptional<FName> Copy;
	Copy = Value;
	TOptional<FName> Expected;
	Expected.Set(n"Red");
	return Copy.IsSet() && Copy == Expected && Copy.GetValue() == n"Red";
}
/** @end */
