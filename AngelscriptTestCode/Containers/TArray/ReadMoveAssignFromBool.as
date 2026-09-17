/**
 * @version v1
 * @summary A const&in TArray<bool> reports MoveAssignFrom contents.
 * @topic Containers
 *
 * ReadMoveAssignFromBool
 */
/**
 * @begin ReadMoveAssignFromBool
 * @summary A const&in TArray<bool> reports MoveAssignFrom contents.
 * @topic Containers
 */
bool ReadMoveAssignFromBool(const TArray<bool>&in Values)
{
	return Values.Num() == 3 && Values[0] == false && Values[1] == true && Values[2] == false;
}
/** @end */
