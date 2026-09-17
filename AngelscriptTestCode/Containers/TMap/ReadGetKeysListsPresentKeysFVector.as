/**
 * @version v1
 * @summary A const&in TMap<int, FVector> reports GetKeys membership without writing the map back.
 * @topic Containers
 *
 * ReadGetKeysListsPresentKeysFVector
 */
/**
 * @begin ReadGetKeysListsPresentKeysFVector
 * @summary A const&in TMap<int, FVector> reports GetKeys membership without writing the map back.
 * @topic Containers
 */
bool ReadGetKeysListsPresentKeysFVector(const TMap<int, FVector>&in Values)
{
	TArray<int> Keys;
	Values.GetKeys(Keys);
	return Keys.Num() == 3 && Keys.Contains(1) && Keys.Contains(2) && Keys.Contains(3);
}
/** @end */
