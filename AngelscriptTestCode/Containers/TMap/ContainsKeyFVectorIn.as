/**
 * @version v1
 * @summary Contains on a const TMap<int,FVector>&in reads present keys without writing the map back.
 * @topic Containers
 *
 * ContainsKeyFVectorIn
 */
/**
 * @begin ContainsKeyFVectorIn
 * @summary Contains on a const TMap<int,FVector>&in reads present keys without writing the map back.
 * @topic Containers
 */
bool ContainsKeyFVectorIn(const TMap<int, FVector>&in Values)
{
	return Values.Contains(1) && Values.Contains(2) && Values.Contains(3);
}
/** @end */
