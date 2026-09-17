/**
 * @version v1
 * @summary Bracket access with a key of the wrong type is rejected.
 * @topic Containers
 *
 * IndexWrongKeyType
 */
/**
 * @begin IndexWrongKeyType
 * @summary Bracket access with a key of the wrong type is rejected.
 * @topic Containers
 */
void IndexWrongKeyType()
{
	TMap<FString, int> Map;
	int X = Map[42];
}
/** @end */
