/**
 * @version v1
 * @summary Contains on a const TMap<FName,int>&in reads present keys without writing the map back.
 * @topic Containers
 *
 * ContainsKeyFNameIn
 */
/**
 * @begin ContainsKeyFNameIn
 * @summary Contains on a const TMap<FName,int>&in reads present keys without writing the map back.
 * @topic Containers
 */
bool ContainsKeyFNameIn(const TMap<FName, int>&in Values)
{
	return Values.Contains(n"Red") && Values.Contains(n"Green") && Values.Contains(n"Blue");
}
/** @end */
