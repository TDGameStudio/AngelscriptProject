/**
 * @version v1
 * @summary A const&in TArray<int32> reports MoveAssignFrom contents.
 * @topic Containers
 *
 * ReadMoveAssignFrom
 */
/**
 * @begin ReadMoveAssignFrom
 * @summary A const&in TArray<int32> reports MoveAssignFrom contents.
 * @topic Containers
 */
bool ReadMoveAssignFrom(const TArray<int32>&in Values)
{
	return Values.Num() == 3 && Values[0] == 1 && Values[1] == 2 && Values[2] == 3;
}
/** @end */
