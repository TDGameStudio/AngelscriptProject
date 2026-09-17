/**
 * @version v1
 * @summary A const&in TMap<int, FVector> reports the overwritten Add value.
 * @topic Containers
 *
 * ReadAddOverwriteReplacesValueFVector
 */
/**
 * @begin ReadAddOverwriteReplacesValueFVector
 * @summary A const&in TMap<int, FVector> reports the overwritten Add value.
 * @topic Containers
 */
bool ReadAddOverwriteReplacesValueFVector(const TMap<int, FVector>&in Values)
{
	return Values.Num() == 1 && Values.Contains(1) && Values[1].Equals(FVector(9.0f, 9.0f, 9.0f));
}
/** @end */
