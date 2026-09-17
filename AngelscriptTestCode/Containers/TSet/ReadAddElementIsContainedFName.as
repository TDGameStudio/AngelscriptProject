/**
 * @version v1
 * @summary A const&in TSet<FName> reports Add membership.
 * @topic Containers
 *
 * ReadAddElementIsContainedFName
 */
/**
 * @begin ReadAddElementIsContainedFName
 * @summary A const&in TSet<FName> reports Add membership.
 * @topic Containers
 */
bool ReadAddElementIsContainedFName(const TSet<FName>&in Values)
{
	return Values.Num() == 3 && Values.Contains(n"Red") && Values.Contains(n"Green") && Values.Contains(n"Blue");
}
/** @end */
