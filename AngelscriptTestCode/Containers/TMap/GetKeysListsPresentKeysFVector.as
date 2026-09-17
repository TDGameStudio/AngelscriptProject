/**
 * @version v1
 * @summary GetKeys copies every int key from an FVector map into the destination array.
 * @topic Containers
 *
 * GetKeysListsPresentKeysFVector
 */
/**
 * @begin GetKeysListsPresentKeysFVector
 * @summary GetKeys copies every int key from an FVector map into the destination array.
 * @topic Containers
 */
bool GetKeysListsPresentKeysFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
	TArray<int> Keys;
	Map.GetKeys(Keys);
	return Keys.Num() == 2 && Keys.Contains(1) && Keys.Contains(2);
}
/** @end */
