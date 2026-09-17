/**
 * @version v1
 * @summary A const&in TSet<FVector> reports membership after a missing Remove.
 * @topic Containers
 *
 * ReadRemoveMissingFVector
 */
/**
 * @begin ReadRemoveMissingFVector
 * @summary A const&in TSet<FVector> reports membership after a missing Remove.
 * @topic Containers
 */
bool ReadRemoveMissingFVector(const TSet<FVector>&in Values)
{
	return Values.Num() == 1 && Values.Contains(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
