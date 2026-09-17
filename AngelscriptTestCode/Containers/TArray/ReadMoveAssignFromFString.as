/**
 * @version v1
 * @summary A const&in TArray<FString> reports MoveAssignFrom contents.
 * @topic Containers
 *
 * ReadMoveAssignFromFString
 */
/**
 * @begin ReadMoveAssignFromFString
 * @summary A const&in TArray<FString> reports MoveAssignFrom contents.
 * @topic Containers
 */
bool ReadMoveAssignFromFString(const TArray<FString>&in Values)
{
	return Values.Num() == 2 && Values[0] == "alpha" && Values[1] == "beta";
}
/** @end */
