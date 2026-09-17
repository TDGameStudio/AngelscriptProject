/**
 * @version v1
 * @summary A const&in TSet<FString> reports Contains false for an absent member.
 * @topic Containers
 *
 * ReadContainsMissingFString
 */
/**
 * @begin ReadContainsMissingFString
 * @summary A const&in TSet<FString> reports Contains false for an absent member.
 * @topic Containers
 */
bool ReadContainsMissingFString(const TSet<FString>&in Values)
{
	return !Values.Contains("missing") && Values.Contains("alpha");
}
/** @end */
