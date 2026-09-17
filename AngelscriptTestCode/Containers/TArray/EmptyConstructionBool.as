/**
 * @version v1
 * @summary Default TArray<bool> is empty.
 * @topic Containers
 *
 * EmptyConstructionBool
 */
/**
 * @begin EmptyConstructionBool
 * @summary Default TArray<bool> is empty.
 * @topic Containers
 */
bool EmptyConstructionBool()
{
	TArray<bool> Values;
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
