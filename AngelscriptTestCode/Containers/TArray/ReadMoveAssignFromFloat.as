/**
 * @version v1
 * @summary A const&in TArray<float> reports MoveAssignFrom contents.
 * @topic Containers
 *
 * ReadMoveAssignFromFloat
 */
/**
 * @begin ReadMoveAssignFromFloat
 * @summary A const&in TArray<float> reports MoveAssignFrom contents.
 * @topic Containers
 */
bool ReadMoveAssignFromFloat(const TArray<float>&in Values)
{
	return Values.Num() == 3 && Values[0] == 1.0f && Values[1] == 2.0f && Values[2] == 3.0f;
}
/** @end */
