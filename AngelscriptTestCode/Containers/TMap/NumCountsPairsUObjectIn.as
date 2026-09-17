/**
 * @version v1
 * @summary Num on a const TMap<int,UObject>&in reports the live pair count without writing the map back.
 * @topic Containers
 *
 * NumCountsPairsUObjectIn
 */
/**
 * @begin NumCountsPairsUObjectIn
 * @summary Num on a const TMap<int,UObject>&in reports the live pair count without writing the map back.
 * @topic Containers
 */
bool NumCountsPairsUObjectIn(const TMap<int, UObject>&in Values)
{
	return Values.Num() == 3;
}
/** @end */
