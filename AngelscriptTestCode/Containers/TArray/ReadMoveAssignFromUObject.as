/**
 * @version v1
 * @summary A const&in TArray<UObject> reports MoveAssignFrom handle count.
 * @topic Containers
 *
 * ReadMoveAssignFromUObject
 */
/**
 * @begin ReadMoveAssignFromUObject
 * @summary A const&in TArray<UObject> reports MoveAssignFrom handle count.
 * @topic Containers
 */
bool ReadMoveAssignFromUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 2 && Values[0] != nullptr && Values[1] != nullptr;
}
/** @end */
