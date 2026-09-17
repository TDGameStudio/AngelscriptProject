/**
 * @version v1
 * @summary A const&in TSet<FString> reports Add membership.
 * @topic Containers
 *
 * ReadAddElementIsContainedFString
 */
/**
 * @begin ReadAddElementIsContainedFString
 * @summary A const&in TSet<FString> reports Add membership.
 * @topic Containers
 */
bool ReadAddElementIsContainedFString(const TSet<FString>&in Values)
{
	return Values.Num() == 3 && Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma");
}
/** @end */
