/**
 * @version v1
 * @summary Contains is false for an FString member that was never added.
 * @topic Containers
 *
 * ContainsMissingFString
 */
/**
 * @begin ContainsMissingFString
 * @summary Contains is false for an FString member that was never added.
 * @topic Containers
 */
bool ContainsMissingFString()
{
	TSet<FString> Values;
	Values.Add("alpha");
	return !Values.Contains("missing") && Values.Contains("alpha");
}
/** @end */
