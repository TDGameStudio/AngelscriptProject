/**
 * @version v1
 * @summary Contains on a const TMap<int,UObject>&in reads present keys without writing the map back.
 * @topic Containers
 *
 * ContainsKeyUObjectIn
 */
/**
 * @begin ContainsKeyUObjectIn
 * @summary Contains on a const TMap<int,UObject>&in reads present keys without writing the map back.
 * @topic Containers
 */
bool ContainsKeyUObjectIn(const TMap<int, UObject>&in Values)
{
	return Values.Contains(10) && Values.Contains(20) && Values.Contains(30);
}
/** @end */
