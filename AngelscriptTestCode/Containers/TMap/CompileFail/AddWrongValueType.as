/**
 * @version v1
 * @summary Add with a value of the wrong type is rejected.
 * @topic Containers
 *
 * AddWrongValueType
 */
/**
 * @begin AddWrongValueType
 * @summary Add with a value of the wrong type is rejected.
 * @topic Containers
 */
void AddWrongValueType()
{
	TMap<FString, int> Map;
	Map.Add("key", "value");
}
/** @end */
