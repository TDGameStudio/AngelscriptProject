/**
 * @version v1
 * @summary A const&in TSet<bool> reports membership after a missing Remove.
 * @topic Containers
 *
 * ReadRemoveMissingBool
 */
/**
 * @begin ReadRemoveMissingBool
 * @summary A const&in TSet<bool> reports membership after a missing Remove.
 * @topic Containers
 */
bool ReadRemoveMissingBool(const TSet<bool>&in Values)
{
	return Values.Num() == 1 && Values.Contains(true);
}
/** @end */
