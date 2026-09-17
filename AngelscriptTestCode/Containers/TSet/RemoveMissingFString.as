/**
 * @version v1
 * @summary Remove of an absent FString member returns false and does not throw.
 * @topic Containers
 *
 * RemoveMissingFString
 */
/**
 * @begin RemoveMissingFString
 * @summary Remove of an absent FString member returns false and does not throw.
 * @topic Containers
 */
bool RemoveMissingFString()
{
	TSet<FString> Values;
	Values.Add("alpha");
	return !Values.Remove("missing") && Values.Num() == 1 && Values.Contains("alpha");
}
/** @end */
