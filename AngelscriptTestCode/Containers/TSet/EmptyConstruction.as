/**
 * @version v1
 * @summary Default TSet<int32> is empty.
 * @topic Containers
 *
 * EmptyConstruction
 */
/**
 * @begin EmptyConstruction
 * @summary Default TSet<int32> is empty.
 * @topic Containers
 */
bool EmptyConstruction()
{
	TSet<int32> Values;
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
