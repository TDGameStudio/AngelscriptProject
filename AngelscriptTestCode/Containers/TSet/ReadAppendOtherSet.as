/**
 * @version v1
 * @summary A const&in TSet<int32> reports Append membership.
 * @topic Containers
 *
 * ReadAppendOtherSet
 */
/**
 * @begin ReadAppendOtherSet
 * @summary A const&in TSet<int32> reports Append membership.
 * @topic Containers
 */
bool ReadAppendOtherSet(const TSet<int32>&in Values)
{
	return Values.Num() == 3 && Values.Contains(1) && Values.Contains(3) && Values.Contains(4);
}
/** @end */
