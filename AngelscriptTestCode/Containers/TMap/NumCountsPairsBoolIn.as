/**
 * @version v1
 * @summary Num on a const TMap<int,bool>&in reports the live pair count without writing the map back.
 * @topic Containers
 *
 * NumCountsPairsBoolIn
 */
/**
 * @begin NumCountsPairsBoolIn
 * @summary Num on a const TMap<int,bool>&in reports the live pair count without writing the map back.
 * @topic Containers
 */
bool NumCountsPairsBoolIn(const TMap<int, bool>&in Values)
{
	return Values.Num() == 3;
}
/** @end */
