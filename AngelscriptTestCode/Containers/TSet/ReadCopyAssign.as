/**
 * @version v1
 * @summary A const&in TSet<int32> reports assigned membership.
 * @topic Containers
 *
 * ReadCopyAssign
 */
/**
 * @begin ReadCopyAssign
 * @summary A const&in TSet<int32> reports assigned membership.
 * @topic Containers
 */
bool ReadCopyAssign(const TSet<int32>&in Values)
{
	return Values.Num() == 2 && Values.Contains(1) && Values.Contains(2);
}
/** @end */
