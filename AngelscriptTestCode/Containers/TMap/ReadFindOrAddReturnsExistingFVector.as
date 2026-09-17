/**
 * @version v1
 * @summary A const&in TMap<int, FVector> reports the existing FindOrAdd value.
 * @topic Containers
 *
 * ReadFindOrAddReturnsExistingFVector
 */
/**
 * @begin ReadFindOrAddReturnsExistingFVector
 * @summary A const&in TMap<int, FVector> reports the existing FindOrAdd value.
 * @topic Containers
 */
bool ReadFindOrAddReturnsExistingFVector(const TMap<int, FVector>&in Values)
{
	return Values.Num() == 1 && Values.Contains(1) && Values[1].Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
