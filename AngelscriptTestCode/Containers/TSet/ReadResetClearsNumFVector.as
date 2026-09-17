/**
 * @version v1
 * @summary A const&in TSet<FVector> reports empty after Reset.
 * @topic Containers
 *
 * ReadResetClearsNumFVector
 */
/**
 * @begin ReadResetClearsNumFVector
 * @summary A const&in TSet<FVector> reports empty after Reset.
 * @topic Containers
 */
bool ReadResetClearsNumFVector(const TSet<FVector>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
