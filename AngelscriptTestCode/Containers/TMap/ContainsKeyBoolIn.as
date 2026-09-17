/**
 * @version v1
 * @summary Contains on a const TMap<int,bool>&in reads present keys without writing the map back.
 * @topic Containers
 *
 * ContainsKeyBoolIn
 */
/**
 * @begin ContainsKeyBoolIn
 * @summary Contains on a const TMap<int,bool>&in reads present keys without writing the map back.
 * @topic Containers
 */
bool ContainsKeyBoolIn(const TMap<int, bool>&in Values)
{
	return Values.Contains(1) && Values.Contains(2) && Values.Contains(3);
}
/** @end */
