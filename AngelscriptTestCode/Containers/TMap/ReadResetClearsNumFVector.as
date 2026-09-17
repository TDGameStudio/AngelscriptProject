/**
 * @version v1
 * @summary A const&in TMap<int, FVector> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumFVector
 */
/**
 * @begin ReadResetClearsNumFVector
 * @summary A const&in TMap<int, FVector> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumFVector(const TMap<int, FVector>&in Values)
{
	return Values.Num() == 0 && Values.IsEmpty();
}
/** @end */
