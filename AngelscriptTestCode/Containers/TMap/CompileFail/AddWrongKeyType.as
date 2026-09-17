/**
 * @version v1
 * @summary Add with a key of the wrong type is rejected.
 * @topic Containers
 *
 * AddWrongKeyType
 */
/**
 * @begin AddWrongKeyType
 * @summary Add with a key of the wrong type is rejected.
 * @topic Containers
 */
void AddWrongKeyType()
{
	TMap<FString, int> Map;
	Map.Add(42, 1);
}
/** @end */
