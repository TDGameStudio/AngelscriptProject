/**
 * @version v1
 * @summary Remove deletes every matching FString and leaves non-matches in place.
 * @topic Containers
 *
 * RemoveAllMatchesFString
 */
/**
 * @begin RemoveAllMatchesFString
 * @summary Remove deletes every matching FString and leaves non-matches in place.
 * @topic Containers
 */
bool RemoveAllMatchesFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("alpha");
	int Removed = Values.Remove("alpha");
	int Missing = Values.Remove("zeta");
	return Removed == 2 && Missing == 0 && Values.Num() == 1 && Values[0] == "beta";
}
/** @end */
