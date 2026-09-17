/**
 * @version v1
 * @summary A const&in TSet<FName> reports assigned membership.
 * @topic Containers
 *
 * ReadCopyAssignFName
 */
/**
 * @begin ReadCopyAssignFName
 * @summary A const&in TSet<FName> reports assigned membership.
 * @topic Containers
 */
bool ReadCopyAssignFName(const TSet<FName>&in Values)
{
	return Values.Num() == 2 && Values.Contains(n"Red") && Values.Contains(n"Green");
}
/** @end */
