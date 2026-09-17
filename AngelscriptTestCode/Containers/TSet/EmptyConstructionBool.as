/**
 * @version v1
 * @summary Default TSet<bool> is empty.
 * @topic Containers
 *
 * EmptyConstructionBool
 */
/**
 * @begin EmptyConstructionBool
 * @summary Default TSet<bool> is empty.
 * @topic Containers
 */
bool EmptyConstructionBool()
{
	TSet<bool> Values;
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
