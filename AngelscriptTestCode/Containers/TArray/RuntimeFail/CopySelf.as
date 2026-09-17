/**
 * @version v1
 * @summary Copy from the same array into itself throws Cannot copy an array into itself.
 * @topic Containers
 *
 * CopySelf
 */
/**
 * @begin CopySelf
 * @summary Copy from the same array into itself throws Cannot copy an array into itself.
 * @topic Containers
 */
void CopySelf()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Copy(Values, 0, 1, 0);
}
/** @end */
