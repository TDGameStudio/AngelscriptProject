/**
 * @version v1
 * @summary A const&in TSet<FString> reports a single unique member after duplicate Add.
 * @topic Containers
 *
 * ReadAddDuplicateIgnoredFString
 */
/**
 * @begin ReadAddDuplicateIgnoredFString
 * @summary A const&in TSet<FString> reports a single unique member after duplicate Add.
 * @topic Containers
 */
bool ReadAddDuplicateIgnoredFString(const TSet<FString>&in Values)
{
	return Values.Num() == 1 && Values.Contains("alpha");
}
/** @end */
