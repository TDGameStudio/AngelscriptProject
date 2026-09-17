/**
 * @version v1
 * @summary Default TArray<FVector> is empty.
 * @topic Containers
 *
 * EmptyConstructionFVector
 */
/**
 * @begin EmptyConstructionFVector
 * @summary Default TArray<FVector> is empty.
 * @topic Containers
 */
bool EmptyConstructionFVector()
{
	TArray<FVector> Values;
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
