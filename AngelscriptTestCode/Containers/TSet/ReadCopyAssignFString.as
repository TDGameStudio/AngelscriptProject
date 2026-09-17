/**
 * @version v1
 * @summary A const&in TSet<FString> reports assigned membership.
 * @topic Containers
 *
 * ReadCopyAssignFString
 */
/**
 * @begin ReadCopyAssignFString
 * @summary A const&in TSet<FString> reports assigned membership.
 * @topic Containers
 */
bool ReadCopyAssignFString(const TSet<FString>&in Values)
{
	return Values.Num() == 2 && Values.Contains("alpha") && Values.Contains("beta");
}
/** @end */
