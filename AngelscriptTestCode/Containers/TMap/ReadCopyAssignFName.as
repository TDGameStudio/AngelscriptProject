/**
 * @version v1
 * @summary A const&in TMap<FName, int> reports assigned pairs.
 * @topic Containers
 *
 * ReadCopyAssignFName
 */
/**
 * @begin ReadCopyAssignFName
 * @summary A const&in TMap<FName, int> reports assigned pairs.
 * @topic Containers
 */
bool ReadCopyAssignFName(const TMap<FName, int>&in Values)
{
	return Values.Num() == 3
		&& Values.Contains(n"Red") && Values.Contains(n"Green") && Values.Contains(n"Blue")
		&& Values[n"Red"] == 1 && Values[n"Green"] == 2 && Values[n"Blue"] == 3;
}
/** @end */
