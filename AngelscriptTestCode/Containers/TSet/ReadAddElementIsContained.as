/**
 * @version v1
 * @summary A const&in TSet<int32> reports Add membership.
 * @topic Containers
 *
 * ReadAddElementIsContained
 */
/**
 * @begin ReadAddElementIsContained
 * @summary A const&in TSet<int32> reports Add membership.
 * @topic Containers
 */
bool ReadAddElementIsContained(const TSet<int32>&in Values)
{
	return Values.Num() == 3 && Values.Contains(10) && Values.Contains(20) && Values.Contains(30);
}
/** @end */
