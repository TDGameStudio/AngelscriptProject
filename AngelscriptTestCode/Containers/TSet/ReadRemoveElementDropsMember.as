/**
 * @version v1
 * @summary A const&in TSet<int32> reports membership after Remove.
 * @topic Containers
 *
 * ReadRemoveElementDropsMember
 */
/**
 * @begin ReadRemoveElementDropsMember
 * @summary A const&in TSet<int32> reports membership after Remove.
 * @topic Containers
 */
bool ReadRemoveElementDropsMember(const TSet<int32>&in Values)
{
	return Values.Num() == 1 && Values.Contains(2) && !Values.Contains(1);
}
/** @end */
