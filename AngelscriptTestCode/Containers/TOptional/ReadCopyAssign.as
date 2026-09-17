/**
 * @version v1
 * @summary A const&in TOptional<int32> copies by assignment and compares equal.
 * @topic Containers
 *
 * ReadCopyAssign
 */
/**
 * @begin ReadCopyAssign
 * @summary A const&in TOptional<int32> copies by assignment and compares equal.
 * @topic Containers
 */
bool ReadCopyAssign(const TOptional<int32>&in Value)
{
	TOptional<int32> Copy;
	Copy = Value;
	TOptional<int32> Expected;
	Expected.Set(7);
	return Copy.IsSet() && Copy == Expected && Copy.GetValue() == 7;
}
/** @end */
