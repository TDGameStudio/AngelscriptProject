/**
 * @version v1
 * @summary Num on a const TMap<FName,int>&in reports the live pair count without writing the map back.
 * @topic Containers
 *
 * NumCountsPairsFNameIn
 */
/**
 * @begin NumCountsPairsFNameIn
 * @summary Num on a const TMap<FName,int>&in reports the live pair count without writing the map back.
 * @topic Containers
 */
bool NumCountsPairsFNameIn(const TMap<FName, int>&in Values)
{
	return Values.Num() == 3;
}
/** @end */
