/**
 * @version v1
 * @summary Bracket access on a const TMap<int,UObject>&in reads stored handles without writing the map back.
 * @topic Containers
 *
 * IndexAccessUObjectIn
 */
/**
 * @begin IndexAccessUObjectIn
 * @summary Bracket access on a const TMap<int,UObject>&in reads stored handles without writing the map back.
 * @topic Containers
 */
bool IndexAccessUObjectIn(const TMap<int, UObject>&in Values)
{
	return Values.Num() == 3 && Values[10] != nullptr && Values[20] != nullptr && Values[30] != nullptr;
}
/** @end */
