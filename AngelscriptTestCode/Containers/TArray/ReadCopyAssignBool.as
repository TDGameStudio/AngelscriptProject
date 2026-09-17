/**
 * @version v1
 * @summary A const&in TArray<bool> reports assigned element order.
 * @topic Containers
 *
 * ReadCopyAssignBool
 */
/**
 * @begin ReadCopyAssignBool
 * @summary A const&in TArray<bool> reports assigned element order.
 * @topic Containers
 */
bool ReadCopyAssignBool(const TArray<bool>&in Values)
{
	return Values.Num() == 2 && Values[0] == false && Values[1] == true;
}
/** @end */
