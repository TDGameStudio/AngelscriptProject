/**
 * @version v1
 * @summary A const&in TSet<bool> reports Append membership.
 * @topic Containers
 *
 * ReadAppendOtherSetBool
 */
/**
 * @begin ReadAppendOtherSetBool
 * @summary A const&in TSet<bool> reports Append membership.
 * @topic Containers
 */
bool ReadAppendOtherSetBool(const TSet<bool>&in Values)
{
	return Values.Num() == 2 && Values.Contains(true) && Values.Contains(false);
}
/** @end */
