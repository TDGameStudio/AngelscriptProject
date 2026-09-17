/**
 * @version v1
 * @summary A const&in TSet<bool> reports Add membership.
 * @topic Containers
 *
 * ReadAddElementIsContainedBool
 */
/**
 * @begin ReadAddElementIsContainedBool
 * @summary A const&in TSet<bool> reports Add membership.
 * @topic Containers
 */
bool ReadAddElementIsContainedBool(const TSet<bool>&in Values)
{
	return Values.Num() == 2 && Values.Contains(true) && Values.Contains(false);
}
/** @end */
