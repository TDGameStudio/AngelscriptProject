/**
 * @version v1
 * @summary A const&in TSet<int32> reports a single unique member after duplicate Add.
 * @topic Containers
 *
 * ReadAddDuplicateIgnored
 */
/**
 * @begin ReadAddDuplicateIgnored
 * @summary A const&in TSet<int32> reports a single unique member after duplicate Add.
 * @topic Containers
 */
bool ReadAddDuplicateIgnored(const TSet<int32>&in Values)
{
	return Values.Num() == 1 && Values.Contains(10);
}
/** @end */
