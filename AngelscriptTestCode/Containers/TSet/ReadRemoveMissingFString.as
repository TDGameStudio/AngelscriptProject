/**
 * @version v1
 * @summary A const&in TSet<FString> reports membership after a missing Remove.
 * @topic Containers
 *
 * ReadRemoveMissingFString
 */
/**
 * @begin ReadRemoveMissingFString
 * @summary A const&in TSet<FString> reports membership after a missing Remove.
 * @topic Containers
 */
bool ReadRemoveMissingFString(const TSet<FString>&in Values)
{
	return Values.Num() == 1 && Values.Contains("alpha");
}
/** @end */
