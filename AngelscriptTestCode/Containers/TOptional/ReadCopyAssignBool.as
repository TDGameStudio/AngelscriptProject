/**
 * @version v1
 * @summary A const&in TOptional<bool> copies by assignment and compares equal.
 * @topic Containers
 *
 * ReadCopyAssignBool
 */
/**
 * @begin ReadCopyAssignBool
 * @summary A const&in TOptional<bool> copies by assignment and compares equal.
 * @topic Containers
 */
bool ReadCopyAssignBool(const TOptional<bool>&in Value)
{
	TOptional<bool> Copy;
	Copy = Value;
	TOptional<bool> Expected;
	Expected.Set(true);
	return Copy.IsSet() && Copy == Expected && Copy.GetValue() == true;
}
/** @end */
