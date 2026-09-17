/**
 * @version v1
 * @summary A const&in TSet<FName> reports membership after Remove.
 * @topic Containers
 *
 * ReadRemoveElementDropsMemberFName
 */
/**
 * @begin ReadRemoveElementDropsMemberFName
 * @summary A const&in TSet<FName> reports membership after Remove.
 * @topic Containers
 */
bool ReadRemoveElementDropsMemberFName(const TSet<FName>&in Values)
{
	return Values.Num() == 1 && Values.Contains(n"Green") && !Values.Contains(n"Red");
}
/** @end */
