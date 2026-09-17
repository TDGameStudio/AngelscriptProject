/**
 * @version v1
 * @summary Num on a const TMap<int,FVector>&in reports the live pair count without writing the map back.
 * @topic Containers
 *
 * NumCountsPairsFVectorIn
 */
/**
 * @begin NumCountsPairsFVectorIn
 * @summary Num on a const TMap<int,FVector>&in reports the live pair count without writing the map back.
 * @topic Containers
 */
bool NumCountsPairsFVectorIn(const TMap<int, FVector>&in Values)
{
	return Values.Num() == 3;
}
/** @end */
