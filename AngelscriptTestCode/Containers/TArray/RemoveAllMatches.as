/**
 * @version v1
 * @summary Remove deletes every matching element and leaves non-matches in place.
 * @topic Containers
 *
 * RemoveAllMatches
 */
/**
 * @begin RemoveAllMatches
 * @summary Remove deletes every matching element and leaves non-matches in place.
 * @topic Containers
 */
bool RemoveAllMatches()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(1);
	int Removed = Values.Remove(1);
	int Missing = Values.Remove(9);
	return Removed == 2 && Missing == 0 && Values.Num() == 1 && Values[0] == 2;
}
/** @end */
