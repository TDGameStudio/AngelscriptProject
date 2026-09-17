/**
 * @version v1
 * @summary Insert at a negative index throws Need to insert between 0 and ArraySize.
 * @topic Containers
 *
 * InsertOutOfBounds
 */
/**
 * @begin InsertOutOfBounds
 * @summary Insert at a negative index throws Need to insert between 0 and ArraySize.
 * @topic Containers
 */
void InsertOutOfBounds()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Insert(9, -1);
}
/** @end */
