/**
 * @version v1
 * @summary A const&in TSet<bool> reports membership after Remove.
 * @topic Containers
 *
 * ReadRemoveElementDropsMemberBool
 */
/**
 * @begin ReadRemoveElementDropsMemberBool
 * @summary A const&in TSet<bool> reports membership after Remove.
 * @topic Containers
 */
bool ReadRemoveElementDropsMemberBool(const TSet<bool>&in Values)
{
	return Values.Num() == 1 && Values.Contains(false) && !Values.Contains(true);
}
/** @end */
