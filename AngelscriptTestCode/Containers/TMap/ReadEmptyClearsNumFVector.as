/**
 * @version v1
 * @summary A const&in TMap<int, FVector> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNumFVector
 */
/**
 * @begin ReadEmptyClearsNumFVector
 * @summary A const&in TMap<int, FVector> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNumFVector(const TMap<int, FVector>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
