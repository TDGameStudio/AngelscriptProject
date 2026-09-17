/**
 * @version v1
 * @summary A const&in TSet<int32> reports membership after a missing Remove.
 * @topic Containers
 *
 * ReadRemoveMissing
 */
/**
 * @begin ReadRemoveMissing
 * @summary A const&in TSet<int32> reports membership after a missing Remove.
 * @topic Containers
 */
bool ReadRemoveMissing(const TSet<int32>&in Values)
{
	return Values.Num() == 1 && Values.Contains(10);
}
/** @end */
