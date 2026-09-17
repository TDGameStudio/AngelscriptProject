/**
 * @version v1
 * @summary A const&in TArray<FVector> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 *
 * ReadRemoveAtSwapFVector
 */
/**
 * @begin ReadRemoveAtSwapFVector
 * @summary A const&in TArray<FVector> reports membership after RemoveAtSwap dropped an index.
 * @topic Containers
 */
bool ReadRemoveAtSwapFVector(const TArray<FVector>&in Values)
{
	return Values.Num() == 3
		&& !Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& !Values[1].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& !Values[2].Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
