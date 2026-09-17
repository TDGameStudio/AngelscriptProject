/**
 * @version v1
 * @summary A const&in TMap<int, FVector> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 *
 * ReadRemoveAndCopyValueFVector
 */
/**
 * @begin ReadRemoveAndCopyValueFVector
 * @summary A const&in TMap<int, FVector> reports an empty map after RemoveAndCopyValue.
 * @topic Containers
 */
bool ReadRemoveAndCopyValueFVector(const TMap<int, FVector>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
