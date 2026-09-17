/**
 * @version v1
 * @summary String index on TArray is rejected.
 * @topic Containers
 *
 * StringIndexAccess
 */
/**
 * @begin StringIndexAccess
 * @summary String index on TArray is rejected.
 * @topic Containers
 */
void StringIndexAccess()
{
	TArray<int> Arr;
	Arr.Add(1);
	int X = Arr["key"];
}
/** @end */
