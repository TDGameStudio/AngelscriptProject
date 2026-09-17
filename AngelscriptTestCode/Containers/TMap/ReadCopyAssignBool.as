/**
 * @version v1
 * @summary A const&in TMap<int, bool> reports assigned pairs.
 * @topic Containers
 *
 * ReadCopyAssignBool
 */
/**
 * @begin ReadCopyAssignBool
 * @summary A const&in TMap<int, bool> reports assigned pairs.
 * @topic Containers
 */
bool ReadCopyAssignBool(const TMap<int, bool>&in Values)
{
	return Values.Num() == 3
		&& Values.Contains(1) && Values.Contains(2) && Values.Contains(3)
		&& Values[1] == true && Values[2] == false && Values[3] == true;
}
/** @end */
