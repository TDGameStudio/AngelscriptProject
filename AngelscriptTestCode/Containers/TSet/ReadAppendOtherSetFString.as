/**
 * @version v1
 * @summary A const&in TSet<FString> reports Append membership.
 * @topic Containers
 *
 * ReadAppendOtherSetFString
 */
/**
 * @begin ReadAppendOtherSetFString
 * @summary A const&in TSet<FString> reports Append membership.
 * @topic Containers
 */
bool ReadAppendOtherSetFString(const TSet<FString>&in Values)
{
	return Values.Num() == 3 && Values.Contains("alpha") && Values.Contains("gamma") && Values.Contains("delta");
}
/** @end */
