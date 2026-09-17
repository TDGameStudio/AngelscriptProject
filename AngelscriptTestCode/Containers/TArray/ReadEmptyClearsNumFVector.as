/**
 * @version v1
 * @summary A const&in TArray<FVector> reports Empty as Num 0.
 * @topic Containers
 *
 * ReadEmptyClearsNumFVector
 */
/**
 * @begin ReadEmptyClearsNumFVector
 * @summary A const&in TArray<FVector> reports Empty as Num 0.
 * @topic Containers
 */
bool ReadEmptyClearsNumFVector(const TArray<FVector>&in Values)
{
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
