/**
 * @version v1
 * @summary Num on a const TMap<FString,int>&in reports the live pair count without writing the map back.
 * @topic Containers
 *
 * NumCountsPairsFStringIn
 */
/**
 * @begin NumCountsPairsFStringIn
 * @summary Num on a const TMap<FString,int>&in reports the live pair count without writing the map back.
 * @topic Containers
 */
bool NumCountsPairsFStringIn(const TMap<FString, int>&in Values)
{
	return Values.Num() == 3;
}
/** @end */
