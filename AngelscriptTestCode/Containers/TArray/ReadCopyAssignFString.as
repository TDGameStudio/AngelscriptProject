/**
 * @version v1
 * @summary A const&in TArray<FString> reports assigned element order.
 * @topic Containers
 *
 * ReadCopyAssignFString
 */
/**
 * @begin ReadCopyAssignFString
 * @summary A const&in TArray<FString> reports assigned element order.
 * @topic Containers
 */
bool ReadCopyAssignFString(const TArray<FString>&in Values)
{
	return Values.Num() == 2 && Values[0] == "alpha" && Values[1] == "beta";
}
/** @end */
