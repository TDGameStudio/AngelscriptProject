/**
 * @version v1
 * @summary Writing [] for a missing key throws Could not find key in map for index operator.
 * @topic Containers
 *
 * IndexMissingKeyWrite
 */
/**
 * @begin IndexMissingKeyWrite
 * @summary Writing [] for a missing key throws Could not find key in map for index operator.
 * @topic Containers
 */
void IndexMissingKeyWrite()
{
	TMap<int, int> Values;
	Values.Add(10, 100);
	Values[99] = 1;
}
/** @end */
