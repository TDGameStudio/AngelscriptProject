/**
 * @version v1
 * @summary Remove deletes every matching bool and leaves non-matches in place.
 * @topic Containers
 *
 * RemoveAllMatchesBool
 */
/**
 * @begin RemoveAllMatchesBool
 * @summary Remove deletes every matching bool and leaves non-matches in place.
 * @topic Containers
 */
bool RemoveAllMatchesBool()
{
	TArray<bool> Values;
	Values.Add(true);
	Values.Add(false);
	Values.Add(true);
	int Removed = Values.Remove(true);
	return Removed == 2 && Values.Num() == 1 && Values[0] == false;
}
/** @end */
