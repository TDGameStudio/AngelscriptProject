/**
 * @version v1
 * @summary Contains on a const TMap<FString,int>&in reads present keys without writing the map back.
 * @topic Containers
 *
 * ContainsKeyFStringIn
 */
/**
 * @begin ContainsKeyFStringIn
 * @summary Contains on a const TMap<FString,int>&in reads present keys without writing the map back.
 * @topic Containers
 */
bool ContainsKeyFStringIn(const TMap<FString, int>&in Values)
{
	return Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma");
}
/** @end */
