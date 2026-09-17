/**
 * @version v1
 * @summary Default TArray<float> is empty.
 * @topic Containers
 *
 * EmptyConstructionFloat
 */
/**
 * @begin EmptyConstructionFloat
 * @summary Default TArray<float> is empty.
 * @topic Containers
 */
bool EmptyConstructionFloat()
{
	TArray<float> Values;
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
