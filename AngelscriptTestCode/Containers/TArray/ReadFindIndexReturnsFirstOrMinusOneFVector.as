/**
 * @version v1
 * @summary A const&in TArray<FVector> reports FindIndex first match or -1.
 * @topic Containers
 *
 * ReadFindIndexReturnsFirstOrMinusOneFVector
 */
/**
 * @begin ReadFindIndexReturnsFirstOrMinusOneFVector
 * @summary A const&in TArray<FVector> reports FindIndex first match or -1.
 * @topic Containers
 */
bool ReadFindIndexReturnsFirstOrMinusOneFVector(const TArray<FVector>&in Values)
{
	return Values.FindIndex(FVector(1.0f, 0.0f, 0.0f)) == 0
		&& Values.FindIndex(FVector(0.0f, 1.0f, 0.0f)) == 1
		&& Values.FindIndex(FVector(1.0f, 1.0f, 1.0f)) == -1;
}
/** @end */
