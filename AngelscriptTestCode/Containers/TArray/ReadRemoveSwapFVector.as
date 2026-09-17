/**
 * @version v1
 * @summary A const&in TArray<FVector> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 *
 * ReadRemoveSwapFVector
 */
/**
 * @begin ReadRemoveSwapFVector
 * @summary A const&in TArray<FVector> reports membership after RemoveSwap deleted every match.
 * @topic Containers
 */
bool ReadRemoveSwapFVector(const TArray<FVector>&in Values)
{
	return Values.Num() == 2
		&& !Values[0].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& !Values[1].Equals(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
