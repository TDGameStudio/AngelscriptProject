/**
 * @version v1
 * @summary A const&in TMap<int, FVector> reports pairs inserted by FindOrAdd.
 * @topic Containers
 *
 * ReadFindOrAddInsertsFVector
 */
/**
 * @begin ReadFindOrAddInsertsFVector
 * @summary A const&in TMap<int, FVector> reports pairs inserted by FindOrAdd.
 * @topic Containers
 */
bool ReadFindOrAddInsertsFVector(const TMap<int, FVector>&in Values)
{
	return Values.Num() == 3 && Values.Contains(1) && Values.Contains(2) && Values.Contains(3);
}
/** @end */
