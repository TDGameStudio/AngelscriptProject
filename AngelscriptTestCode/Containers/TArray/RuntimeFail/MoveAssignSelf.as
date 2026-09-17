/**
 * @version v1
 * @summary MoveAssignFrom the same array throws Cannot move assign an array into itself.
 * @topic Containers
 *
 * MoveAssignSelf
 */
/**
 * @begin MoveAssignSelf
 * @summary MoveAssignFrom the same array throws Cannot move assign an array into itself.
 * @topic Containers
 */
void MoveAssignSelf()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.MoveAssignFrom(Values);
}
/** @end */
