/**
 * @version v1
 * @summary A const&in TSet<FName> reports Append membership.
 * @topic Containers
 *
 * ReadAppendOtherSetFName
 */
/**
 * @begin ReadAppendOtherSetFName
 * @summary A const&in TSet<FName> reports Append membership.
 * @topic Containers
 */
bool ReadAppendOtherSetFName(const TSet<FName>&in Values)
{
	return Values.Num() == 3 && Values.Contains(n"Red") && Values.Contains(n"Blue") && Values.Contains(n"Yellow");
}
/** @end */
