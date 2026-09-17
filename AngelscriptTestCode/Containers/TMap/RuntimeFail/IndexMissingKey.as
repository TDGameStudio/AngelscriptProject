/**
 * @version v1
 * @summary Reading [] for a missing key throws Could not find key in map for index operator.
 * @topic Containers
 *
 * IndexMissingKey
 */
/**
 * @begin IndexMissingKey
 * @summary Reading [] for a missing key throws Could not find key in map for index operator.
 * @topic Containers
 */
void IndexMissingKey()
{
	TMap<int, int> Values;
	Values.Add(10, 100);
	int Missing = Values[99];
}
/** @end */
