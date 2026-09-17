/**
 * @version v1
 * @summary A const&in TSet<FString> reports membership after Remove.
 * @topic Containers
 *
 * ReadRemoveElementDropsMemberFString
 */
/**
 * @begin ReadRemoveElementDropsMemberFString
 * @summary A const&in TSet<FString> reports membership after Remove.
 * @topic Containers
 */
bool ReadRemoveElementDropsMemberFString(const TSet<FString>&in Values)
{
	return Values.Num() == 1 && Values.Contains("beta") && !Values.Contains("alpha");
}
/** @end */
