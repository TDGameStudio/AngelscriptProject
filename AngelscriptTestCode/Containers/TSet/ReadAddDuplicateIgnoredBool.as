/**
 * @version v1
 * @summary A const&in TSet<bool> reports a single unique member after duplicate Add.
 * @topic Containers
 *
 * ReadAddDuplicateIgnoredBool
 */
/**
 * @begin ReadAddDuplicateIgnoredBool
 * @summary A const&in TSet<bool> reports a single unique member after duplicate Add.
 * @topic Containers
 */
bool ReadAddDuplicateIgnoredBool(const TSet<bool>&in Values)
{
	return Values.Num() == 1 && Values.Contains(true);
}
/** @end */
