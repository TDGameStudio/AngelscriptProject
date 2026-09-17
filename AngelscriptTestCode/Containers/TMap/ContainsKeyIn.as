/**
 * @version v1
 * @summary Contains on a const TMap<int,int>&in reads present keys without writing the map back.
 * @topic Containers
 *
 * ContainsKeyIn
 */
/**
 * @begin ContainsKeyIn
 * @summary Contains on a const TMap<int,int>&in reads present keys without writing the map back.
 * @topic Containers
 */
bool ContainsKeyIn(const TMap<int, int>&in Values)
{
	return Values.Contains(10) && Values.Contains(20) && Values.Contains(30);
}
/** @end */
