/**
 * @version v1
 * @summary A const&in TSet<bool> reports assigned membership.
 * @topic Containers
 *
 * ReadCopyAssignBool
 */
/**
 * @begin ReadCopyAssignBool
 * @summary A const&in TSet<bool> reports assigned membership.
 * @topic Containers
 */
bool ReadCopyAssignBool(const TSet<bool>&in Values)
{
	return Values.Num() == 2 && Values.Contains(true) && Values.Contains(false);
}
/** @end */
