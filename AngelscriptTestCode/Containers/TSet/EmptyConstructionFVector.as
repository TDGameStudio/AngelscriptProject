/**
 * @version v1
 * @summary Default TSet<FVector> is empty.
 * @topic Containers
 *
 * EmptyConstructionFVector
 */
/**
 * @begin EmptyConstructionFVector
 * @summary Default TSet<FVector> is empty.
 * @topic Containers
 */
bool EmptyConstructionFVector()
{
	TSet<FVector> Values;
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
